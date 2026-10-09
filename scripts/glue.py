#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages(ps: [ ps.dnspython ps.ovh ps.requests ])"
#
# glue.py — make the delegation at the registrar match what the zone itself
#           says, for domains registered at OVH or IONOS.
#
#   ./scripts/glue.py                     # every domain, dry run
#   ./scripts/glue.py mndn.fr             # one domain, dry run
#   ./scripts/glue.py --apply             # write it
#
# With --dnssec it publishes the zone's signing key at the registry instead, so
# that resolvers start validating. The key is read from the zone as well, so the
# signer needs no shell access. Publish it only once every nameserver answers
# with the signed zone: from then on a broken signature is a dark domain, not a
# stale one.
#
#   ./scripts/glue.py --dnssec            # what the registries would get
#   ./scripts/glue.py --dnssec --apply
#
# The nameserver names and their addresses are read from the primary over DNS,
# so the zone in this repository stays the only place they are written down:
# deploy first, then run this.
#
# Credentials live in one file per registrar (chmod 600); either may be absent,
# and only the domains of the accounts it finds are touched.
#
# A file holds one account, so a second account is a second file:
#
#   ./scripts/glue.py --ovh-config ~/.ovh.conf --ovh-config ~/.ovh-other.conf
#
#   ~/.ovh.conf     the python-ovh ini:  [default] endpoint = ovh-eu
#                                        [ovh-eu]  application_key = ...
#                                                  application_secret = ...
#                                                  consumer_key = ...
#   ~/.ionos.conf   [ionos] api_key = <public prefix>.<secret>
#
# An OVH consumer key expires or gets revoked; --login asks for a new one for
# the application already in ~/.ovh.conf, writes it there and prints the URL to
# validate it with. The key is inert until that page is opened.
#
#   ./scripts/glue.py --login
#
# OVH token:  https://eu.api.ovh.com/createToken/ with GET PUT POST DELETE on /domain/*
#             (a fresh application; to reuse the one you have, --login instead)
# IONOS key:  the developer portal of the account's country, e.g.
#             https://developer.hosting.ionos.fr/keys — the API host is
#             api.hosting.ionos.com whatever the country.

import argparse
import base64
import configparser
import io
import ipaddress
import json
import os
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor

import dns.dnssec
import dns.flags
import dns.message
import dns.name
import dns.query
import dns.rdatatype
import dns.resolver
import ovh
import requests
from ovh.exceptions import APIError

# zeppelin over the tailnet: the machine that holds and signs the zones.
PRIMARY = "fd7a:115c:a1e0::7"
PRIMARY_HOST = "zeppelin"

OVH_CONFIG = "~/.ovh.conf"
IONOS_CONFIG = "~/.ionos.conf"

IONOS_BASE = "https://api.hosting.ionos.com/domains"

class Problem(Exception):
    """Something wrong with one domain: the others are still worth doing."""


class Output:
    """Stdout a worker can capture for itself, so each domain prints in one piece."""

    def __init__(self, real):
        self.real = real
        self.local = threading.local()

    def _buffer(self):
        return getattr(self.local, "buffer", None)

    def write(self, text):
        (self._buffer() or self.real).write(text)

    def flush(self):
        if self._buffer() is None:
            self.real.flush()

    def capturing(self):
        return self._buffer() is not None

    def capture(self):
        self.local.buffer = io.StringIO()

    def release(self):
        buffer = self._buffer()
        self.local.buffer = None
        return buffer.getvalue() if buffer else ""


def fail(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def warn(msg):
    # Through stdout, so a warning stays inside the domain block it belongs to.
    print(f"!  {msg}")


def buffered():
    return isinstance(sys.stdout, Output) and sys.stdout.capturing()


def ticker(msg):
    """A status that overwrites itself; worthless once the output is a buffer."""
    if not buffered():
        print(f"\r{msg}   ", end="", flush=True)


def settled(msg):
    """The line that replaces a ticker."""
    print(f"\r{msg}" + " " * 40 if not buffered() else msg)


def canon(ip):
    """One spelling per address, so ::2 and 0:0:0:2 compare equal."""
    try:
        return str(ipaddress.ip_address(ip))
    except ValueError:
        raise Problem(f"not an address: {ip}") from None


### The zone as served by the primary


def query(server, name, rdtype, tries=2):
    """One non-recursive question, retried, over TCP if the answer is truncated."""
    q = dns.message.make_query(name, rdtype)
    q.flags &= ~dns.flags.RD
    last = None
    for attempt in range(tries):
        try:
            answer = dns.query.udp(q, server, timeout=5)
            if answer.flags & dns.flags.TC:
                answer = dns.query.tcp(q, server, timeout=10)
            return answer
        except Exception as e:  # noqa: BLE001 — any failure is worth one retry
            last = e
            if attempt + 1 < tries:
                time.sleep(1)
    raise Problem(f"asking {server} for {name} {rdtype}: {last}")


def ask(server, name, rdtype):
    """The records of that type in the answer section."""
    answer = query(server, name, rdtype)
    return [
        item
        for rrset in answer.answer
        if rrset.rdtype == dns.rdatatype.from_text(rdtype)
        for item in rrset
    ]


def served(server, domain):
    """Whether the server answers authoritatively for the domain."""
    try:
        answer = query(server, domain, "SOA", tries=1)
    except Problem:
        return False
    return bool(answer.flags & dns.flags.AA) and bool(answer.answer)


def desired(primary, domain, force=False):
    """The in-zone nameservers of the domain, each with its own addresses."""
    hosts = {}
    for ns in ask(primary, domain, "NS"):
        name = str(ns.target).rstrip(".").lower()
        if not (name == domain or name.endswith(f".{domain}")):
            # A nameserver outside the zone needs no glue: the parent resolves it.
            continue
        hosts[name] = {
            "v4": sorted({canon(str(r)) for r in ask(primary, name, "A")}),
            "v6": sorted({canon(str(r)) for r in ask(primary, name, "AAAA")}),
        }
    if not hosts:
        raise Problem("the primary lists no in-zone nameserver")

    for name, addrs in hosts.items():
        if not addrs["v4"] and not addrs["v6"]:
            raise Problem(f"{name} has no address in the zone")
        # A glue address the internet cannot route would strand the delegation.
        for ip in addrs["v4"] + addrs["v6"]:
            if not ipaddress.ip_address(ip).is_global:
                raise Problem(f"{name} has the non-public address {ip}")

    if len(hosts) < 2 and not force:
        raise Problem(
            f"only {len(hosts)} nameserver in the zone — registries want two "
            "(pass --force to publish anyway)"
        )

    if not force:
        # Publishing a nameserver that does not answer is how a domain goes dark.
        for name, addrs in hosts.items():
            for ip in addrs["v4"] + addrs["v6"]:
                if not served(ip, domain):
                    raise Problem(
                        f"{name} at {ip} does not answer authoritatively for "
                        f"{domain} (deploy it first, or pass --force)"
                    )

    return dict(sorted(hosts.items()))


def signing_keys(primary, domain):
    """The zone's key-signing keys, in both forms the registries ask for."""
    keys = []
    for key in ask(primary, domain, "DNSKEY"):
        if not key.flags & 0x0001:
            # Not a secure entry point: the parent never points at it.
            continue
        ds = dns.dnssec.make_ds(dns.name.from_text(domain), key, "SHA256")
        keys.append(
            {
                "key_tag": int(dns.dnssec.key_id(key)),
                "algorithm": int(key.algorithm),
                "flags": int(key.flags),
                "public_key": base64.b64encode(key.key).decode(),
                "digest_type": int(ds.digest_type),
                "digest": ds.digest.hex().upper(),
            }
        )
    if not keys:
        raise Problem("the zone publishes no key-signing key — is it signed?")
    return keys


def zones(host):
    """The zones the primary serves, from its configuration in this repository."""
    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    expr = (
        f"builtins.attrNames (import {repo})"
        f'.nixosConfigurations."{host}".config.services.knot.settings.zone'
    )
    try:
        out = subprocess.run(
            ["nix-instantiate", "--eval", "--strict", "--json", "-E", expr],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    except FileNotFoundError:
        fail("nix-instantiate is not on PATH — pass the domains explicitly")
    except subprocess.CalledProcessError as e:
        fail(f"reading the zones of {host}: {e.stderr.strip()}")
    return sorted(json.loads(out))


def show(name, addrs):
    joined = ", ".join(addrs["v4"] + addrs["v6"]) or "no address"
    return f"{name}  {joined}"


### Registrars


class Ovh:
    name = "OVH"

    def __init__(self, path, apply):
        self.path = path
        self.apply = apply
        self.broken = False
        # A client and its queued tasks belong to one thread: domains run in
        # parallel and must not poll each other's tasks.
        self.local = threading.local()
        try:
            ovh.Client(config_file=path)
        except Exception as e:
            fail(f"{path}: {e}")

    @property
    def c(self):
        if not hasattr(self.local, "client"):
            self.local.client = ovh.Client(config_file=self.path)
        return self.local.client

    @property
    def tasks(self):
        if not hasattr(self.local, "tasks"):
            self.local.tasks = []
        return self.local.tasks

    def get(self, path, **kw):
        try:
            return self.c.get(path, **kw)
        except APIError as e:
            fail(f"GET {path}: {e}")

    def write(self, method, path, **body):
        if not self.apply:
            shown = ", ".join(f"{k}={v!r}" for k, v in body.items())
            print(f"   would {method} {path}" + (f"  [{shown}]" if shown else ""))
            return None
        print(f"   {method} {path}")
        try:
            res = getattr(self.c, method.lower())(path, **body)
        except APIError as e:
            fail(f"{method} {path}: {e}")
        # Every write on /domain answers with the registry task it queued.
        if isinstance(res, dict) and res.get("id") and res.get("function"):
            self.tasks.append(res["id"])
        return res

    def info(self, domain):
        """The domain's capabilities, asked once per thread."""
        cache = self.local.__dict__.setdefault("info", {})
        if domain not in cache:
            cache[domain] = self.get(f"/domain/{domain}")
        return cache[domain]

    def owns(self, domain):
        if self.broken:
            return False
        try:
            self.local.__dict__.setdefault("info", {})[domain] = self.c.get(f"/domain/{domain}")
            return True
        except APIError as e:
            if "credential" in str(e).lower():
                # Say so once: every domain would fail the same way.
                self.broken = True
                warn(
                    f"OVH rejects the credentials ({str(e).splitlines()[0].strip()}) — "
                    "create a token at https://eu.api.ovh.com/createToken/ with "
                    "GET PUT POST on /domain/*"
                )
            return False

    def current(self, domain):
        hosts = {}
        for nid in self.get(f"/domain/{domain}/nameServer"):
            ns = self.get(f"/domain/{domain}/nameServer/{nid}")
            hosts[ns["host"].rstrip(".").lower()] = {"v4": [], "v6": []}
        for host in self.get(f"/domain/{domain}/glueRecord"):
            rec = self.get(f"/domain/{domain}/glueRecord/{host}")
            key = rec["host"].rstrip(".").lower()
            entry = hosts.setdefault(key, {"v4": [], "v6": []})
            for ip in rec.get("ips", []):
                entry["v6" if ":" in ip else "v4"].append(canon(ip))
        return {n: {f: sorted(set(v)) for f, v in a.items()} for n, a in hosts.items()}

    def wait(self, domain, timeout=300):
        """Follow the tasks queued by our own writes; a failed one stops the run."""
        if not self.apply or not self.tasks:
            return
        deadline = time.time() + timeout
        pending = {}
        while time.time() < deadline:
            pending = {}
            for tid in self.tasks:
                t = self.get(f"/domain/{domain}/task/{tid}")
                if t["status"] in ("cancelled", "error", "problem"):
                    print()
                    comment = " ".join((t.get("comment") or "").split())
                    fail(f"task {tid} {t['function']} {t['status']}: {comment or 'no comment'}")
                if t["status"] != "done":
                    pending[tid] = t
            if not pending:
                settled("   tasks done")
                self.tasks.clear()
                return
            ticker(f"   waiting on {len(pending)} pending task(s)…")
            time.sleep(5)
        print()
        for tid, t in pending.items():
            comment = " ".join((t.get("comment") or "").split())
            warn(f"task {tid} {t['function']} still {t['status']} after {timeout}s: {comment or 'no comment'}")
        self.tasks.clear()

    def push(self, domain, hosts):
        info = self.info(domain)
        if not info.get("glueRecordIpv6Supported"):
            warn("registry rejects IPv6 glue — dropping the AAAA addresses")
            hosts = {n: {"v4": a["v4"], "v6": []} for n, a in hosts.items()}
        if not info.get("glueRecordMultiIpSupported"):
            warn("registry allows one address per host — keeping the first of each family")
            hosts = {
                n: {"v4": a["v4"][:1], "v6": a["v6"][:1]} for n, a in hosts.items()
            }

        for status in ("todo", "doing", "error", "problem"):
            for tid in self.get(f"/domain/{domain}/task", status=status):
                t = self.get(f"/domain/{domain}/task/{tid}")
                comment = " ".join((t.get("comment") or "").split())
                warn(f"task {tid} {t['function']} already {status}: {comment or 'no comment'}")
                warn(f"  settle it with POST /domain/{domain}/task/{tid}/relaunch or …/cancel")

        if info.get("nameServerType") != "external":
            print("   switching nameServerType → external")
            self.write("PUT", f"/domain/{domain}", nameServerType="external")

        if info.get("hostSupported"):
            # Hosts are first-class registry objects: create or update each, let
            # the registry acknowledge them, only then point the domain at them.
            existing = set(self.get(f"/domain/{domain}/glueRecord"))
            for name, addrs in hosts.items():
                ips = addrs["v4"] + addrs["v6"]
                if name in existing:
                    self.write("POST", f"/domain/{domain}/glueRecord/{name}/update", ips=ips)
                else:
                    self.write("POST", f"/domain/{domain}/glueRecord", host=name, ips=ips)
            self.wait(domain)

        if not info.get("hostSupported"):
            for name, addrs in hosts.items():
                if not addrs["v4"]:
                    # Without host objects the address rides in the declaration,
                    # and these registries take an IPv4 one.
                    warn(f"{name} has no IPv4 address and this registry has no host objects")

        # The hosts live inside the zone they serve, so the declaration carries
        # an address of its own; the full set stays on the host object.
        self.write(
            "POST",
            f"/domain/{domain}/nameServers/update",
            nameServers=[
                {"host": name, "ip": (addrs["v4"] or addrs["v6"])[0]}
                for name, addrs in hosts.items()
            ],
        )
        self.wait(domain)

    def stale_hosts(self, domain, hosts):
        """Registry host objects no nameserver of the domain uses any more."""
        if not self.info(domain).get("hostSupported"):
            return []
        return [
            host
            for host in self.get(f"/domain/{domain}/glueRecord")
            if host.rstrip(".").lower() not in hosts
        ]

    def drop_hosts(self, domain, names):
        # Safe only once the declaration no longer points at them: the registry
        # refuses to drop a host the domain still uses.
        for host in names:
            self.write("DELETE", f"/domain/{domain}/glueRecord/{host}")
        self.wait(domain)

    def dnssec(self, domain):
        try:
            return len(self.c.get(f"/domain/{domain}/dsRecord") or [])
        except APIError:
            return 0

    def current_ds(self, domain):
        out = []
        for kid in self.get(f"/domain/{domain}/dsRecord"):
            rec = self.get(f"/domain/{domain}/dsRecord/{kid}")
            out.append(
                {
                    "key_tag": rec.get("tag"),
                    "label": f"keyTag {rec.get('tag')}  alg {rec.get('algorithm')}  {rec.get('status')}",
                }
            )
        return out

    def push_ds(self, domain, keys):
        # OVH takes the key itself and derives the DS at the registry. Its
        # dnssec.Key is {tag, flags, algorithm, publicKey}, all numbers but the key.
        self.write(
            "POST",
            f"/domain/{domain}/dsRecord",
            keys=[
                {
                    "tag": k["key_tag"],
                    "flags": k["flags"],
                    "algorithm": k["algorithm"],
                    "publicKey": k["public_key"],
                }
                for k in keys
            ],
        )
        self.wait(domain)


class Ionos:
    name = "IONOS"

    def __init__(self, path, apply):
        cfg = configparser.ConfigParser()
        if not cfg.read(path):
            fail(f"could not read {path}")
        try:
            key = cfg["ionos"]["api_key"].strip()
        except KeyError:
            fail(f"{path}: missing [ionos] api_key")
        self.key = key
        self.apply = apply
        self.ids = {}
        # A session per thread: domains run in parallel.
        self.local = threading.local()

    @property
    def s(self):
        if not hasattr(self.local, "session"):
            session = requests.Session()
            session.headers.update({"X-Api-Key": self.key, "Accept": "application/json"})
            self.local.session = session
        return self.local.session

    def call(self, method, path, **kw):
        try:
            resp = self.s.request(method, IONOS_BASE + path, timeout=30, **kw)
        except requests.RequestException as e:
            fail(f"{method} {path}: {e}")
        if resp.status_code >= 400:
            fail(f"{method} {path}: HTTP {resp.status_code} {resp.text.strip()}")
        return resp.json() if resp.content else None

    def get(self, path, **params):
        return self.call("GET", path, params=params)

    def owns(self, domain):
        listing = self.get("/v1/domainitems", name=domain, limit=100)
        for d in listing.get("domains", []):
            self.ids[d.get("name", "").lower()] = d
        return domain in self.ids

    def item(self, domain):
        if domain not in self.ids:
            # `name` filters loosely, so match the exact name out of the answer.
            listing = self.get("/v1/domainitems", name=domain, limit=100)
            for d in listing.get("domains", []):
                self.ids[d.get("name", "").lower()] = d
        if domain not in self.ids:
            fail(f"{domain} is not a domain of this IONOS account")
        return self.ids[domain]

    def current(self, domain):
        item = self.item(domain)
        answer = self.get(f"/v1/domainitems/{item['id']}/nameservers")
        return {
            ns["name"].rstrip(".").lower(): {
                "v4": sorted({canon(ip) for ip in ns.get("ipV4Addresses", [])}),
                "v6": sorted({canon(ip) for ip in ns.get("ipV6Addresses", [])}),
            }
            for ns in answer.get("nameservers", [])
        }

    def stale_hosts(self, domain, hosts):
        # IONOS keeps no host objects: the declaration is the whole state, so
        # nothing is ever left behind.
        return []

    def drop_hosts(self, domain, names):
        raise Problem("IONOS has no host objects to drop")

    def push(self, domain, hosts):
        item = self.item(domain)
        tld = self.get(f"/v1/tlds/{item['tld']}")
        if item.get("pendingProvisioning"):
            fail("domain is still being provisioned — IONOS refuses updates until it settles")
        if not tld.get("updateNameserverSupported"):
            fail(f".{item['tld']} does not allow nameserver updates through IONOS")
        if not tld.get("glueNameserverSupported"):
            fail(f".{item['tld']} does not allow glue nameservers through IONOS")

        # IONOS has no host objects: the addresses ride in the declaration.
        entries = []
        for name, addrs in hosts.items():
            entry = {"name": name}
            if addrs["v4"]:
                entry["ipV4Addresses"] = addrs["v4"]
            if addrs["v6"]:
                entry["ipV6Addresses"] = addrs["v6"]
            entries.append(entry)
        body = {"nameservers": entries}

        path = f"/v1/domainitems/{item['id']}/nameservers"
        if not self.apply:
            print(f"   would PUT {path}")
            for entry in entries:
                print(f"      {entry}")
            return
        print(f"   PUT {path}")
        res = self.call("PUT", path, json=body)
        if res and res.get("id"):
            self.wait(res["id"])

    def wait(self, req_id, timeout=300):
        deadline = time.time() + timeout
        while time.time() < deadline:
            req = self.get(f"/v1/requests/{req_id}")
            status = req.get("status")
            if status == "FINISHED":
                settled("   request finished")
                return
            if status in ("FAILED", "CANCELLED"):
                print()
                fail(f"request {req_id} {status}: {req.get('errors') or req.get('details')}")
            ticker(f"   waiting on request {req_id} ({status})…")
            time.sleep(5)
        print()
        warn(f"request still pending after {timeout}s — check /v1/requests/{req_id}")

    def dnssec(self, domain):
        item = self.item(domain)
        sec = (self.get(f"/v1/domainitems/{item['id']}/dnssec") or {}).get("secDns") or {}
        return len(sec.get("dsData") or []) + len(sec.get("keyData") or [])

    def current_ds(self, domain):
        item = self.item(domain)
        sec = (self.get(f"/v1/domainitems/{item['id']}/dnssec") or {}).get("secDns") or {}
        return [
            {
                "key_tag": d.get("keyTag"),
                "label": f"keyTag {d.get('keyTag')}  alg {d.get('alg')}  digestType {d.get('digestType')}",
            }
            for d in sec.get("dsData") or []
        ] + [
            {"key_tag": None, "label": f"key alg {k.get('alg')}  flags {k.get('flags')}"}
            for k in sec.get("keyData") or []
        ]

    def push_ds(self, domain, keys):
        # IONOS takes the digest, which the zone's key gives us directly.
        item = self.item(domain)
        body = {
            "secDns": {
                "dsData": [
                    {
                        "keyTag": k["key_tag"],
                        "alg": k["algorithm"],
                        "digestType": k["digest_type"],
                        "digest": k["digest"],
                    }
                    for k in keys
                ]
            }
        }
        path = f"/v1/domainitems/{item['id']}/dnssec"
        if not self.apply:
            print(f"   would PUT {path}")
            for entry in body["secDns"]["dsData"]:
                print(f"      {entry}")
            return
        print(f"   PUT {path}")
        res = self.call("PUT", path, json=body)
        if res and res.get("id"):
            self.wait(res["id"])


### Driver


def ovh_login(path):
    """Ask OVH for a new consumer key for the application already configured."""
    cfg = configparser.ConfigParser()
    if not cfg.read(path):
        fail(f"could not read {path}")
    endpoint = cfg.get("default", "endpoint", fallback="ovh-eu").strip()
    try:
        section = cfg[endpoint]
        key, secret = section["application_key"].strip(), section["application_secret"].strip()
    except KeyError:
        fail(f"{path}: [{endpoint}] needs application_key and application_secret")

    try:
        client = ovh.Client(endpoint=endpoint, application_key=key, application_secret=secret)
        request = client.new_consumer_key_request()
        request.add_recursive_rules(ovh.API_READ_WRITE, "/domain")
        validation = request.request()
    except Exception as e:  # noqa: BLE001 — the API reports every refusal this way
        fail(f"requesting a consumer key: {e}")

    consumer_key = validation["consumerKey"]

    # Keep the file as it is apart from the one line, so comments survive.
    with open(path) as handle:
        lines = handle.readlines()
    for i, line in enumerate(lines):
        if line.lstrip().startswith("consumer_key"):
            lines[i] = f"consumer_key       = {consumer_key}\n"
            break
    else:
        for i, line in enumerate(lines):
            if line.strip() == f"[{endpoint}]":
                lines.insert(i + 1, f"consumer_key       = {consumer_key}\n")
                break
        else:
            lines += [f"\n[{endpoint}]\n", f"consumer_key       = {consumer_key}\n"]
    with open(path, "w") as handle:
        handle.writelines(lines)
    os.chmod(path, 0o600)

    print(f"a new consumer key is in {path}, read-write on /domain")
    print("it stays inert until you log in here:")
    print()
    print(f"   {validation['validationUrl']}")
    print()
    print("then:  ./scripts/glue.py")


def do_glue(a, backend, domain):
    """Make the registrar's nameservers and glue match the zone. Returns 1 if changed."""
    want = desired(a.primary, domain, a.force)
    have = backend.current(domain)

    print("   zone declares:")
    for name, addrs in want.items():
        print(f"      {show(name, addrs)}")
    print("   registrar has:")
    for name, addrs in sorted(have.items()):
        print(f"      {show(name, addrs)}")

    if want == have:
        print("   already matches")
        # Leftover host objects outlive a delegation that is otherwise correct.
        return prune(a, backend, domain, want)

    gone = sorted(set(have) - set(want))
    if gone:
        warn(
            f"{', '.join(gone)} will no longer be a nameserver of {domain}"
            + ("" if a.prune else " (its host object stays; --prune removes it)")
        )

    keys = backend.dnssec(domain)
    if keys:
        # Validators follow the DS through the move, so the new nameservers
        # have to serve the same signed zone before the delegation changes.
        warn(
            f"{keys} DNSSEC record(s) at the registry — the new nameservers must "
            "already serve the signed zone, or withdraw the DS first"
        )

    backend.push(domain, want)
    prune(a, backend, domain, want)
    return 1


def prune(a, backend, domain, want):
    """Drop registry host objects the delegation no longer uses. Returns 1 if any."""
    if not a.prune:
        return 0
    stale = backend.stale_hosts(domain, want)
    if not stale:
        print("   no host object to prune")
        return 0
    for host in stale:
        print(f"   stale host object: {host}")
    backend.drop_hosts(domain, stale)
    return 1


def do_dnssec(a, backend, domain):
    """Publish the zone's signing key at the registry. Returns 1 if changed."""
    keys = signing_keys(a.primary, domain)
    print("   zone signs with:")
    for k in keys:
        print(f"      keyTag {k['key_tag']}  alg {k['algorithm']}  digest {k['digest'][:16]}…")

    current = backend.current_ds(domain)
    print("   registry has:")
    for entry in current or [{"label": "nothing (unvalidated)"}]:
        print(f"      {entry['label']}")

    published = {e["key_tag"] for e in current if e.get("key_tag") is not None}
    if published and all(k["key_tag"] in published for k in keys):
        print("   already published")
        return 0

    if not a.force:
        # A DS nobody can validate against is an outage: every nameserver the
        # zone names has to serve the signed zone first.
        for name, addrs in desired(a.primary, domain, a.force).items():
            for ip in addrs["v4"] + addrs["v6"]:
                if not ask(ip, domain, "DNSKEY"):
                    raise Problem(
                        f"{name} at {ip} serves no DNSKEY for {domain} — it would "
                        "fail validation (deploy it first, or pass --force)"
                    )

    backend.push_ds(domain, keys)
    return 1


def handle(a, backends, domain):
    """One domain from start to finish. Returns (changed, skipped)."""
    try:
        if not served(a.primary, domain):
            raise Problem(f"{a.primary} is not authoritative for it")

        # Whoever holds it answers for it, so no registrar on the command line.
        backend = next((b for b in backends if b.owns(domain)), None)
        if backend is None:
            raise Problem("in none of the configured accounts")
        print(f"{domain}  ({backend.name})")

        if a.dnssec:
            return do_dnssec(a, backend, domain), 0
        return do_glue(a, backend, domain), 0
    except Problem as e:
        # One bad domain must not stop the others.
        warn(f"{domain}: {e} — skipping")
        return 0, 1


def parse_args():
    p = argparse.ArgumentParser(
        description="Match the registrar's delegation to what the zone declares."
    )
    p.add_argument("domains", nargs="*", help="default: every domain of every account")
    # Repeatable: one file per account, since each holds a single credential set.
    p.add_argument(
        "--ovh-config", action="append", metavar="FILE", help=f"default: {OVH_CONFIG}"
    )
    p.add_argument(
        "--ionos-config", action="append", metavar="FILE", help=f"default: {IONOS_CONFIG}"
    )
    p.add_argument("-p", "--primary", default=PRIMARY, help=f"read the zone here (default: {PRIMARY})")
    p.add_argument("--host", default=PRIMARY_HOST, help=f"whose zones to publish (default: {PRIMARY_HOST})")
    p.add_argument(
        "--dnssec",
        action="store_true",
        help="publish the zone's signing key at the registry instead of the glue",
    )
    p.add_argument(
        "--jobs",
        type=int,
        default=4,
        metavar="N",
        help="domains to work on at once (default: 4)",
    )
    p.add_argument("--apply", action="store_true", help="actually write (default: dry run)")
    p.add_argument(
        "--prune",
        action="store_true",
        help="also delete registry host objects no nameserver uses any more",
    )
    p.add_argument(
        "--force",
        action="store_true",
        help="skip the checks that the nameservers answer and that there are two of them",
    )
    p.add_argument(
        "--login",
        action="store_true",
        help="get a new OVH consumer key for the configured application and stop",
    )
    return p.parse_args()


def main():
    a = parse_args()

    ovh_paths = [os.path.expanduser(p) for p in a.ovh_config or [OVH_CONFIG]]
    ionos_paths = [os.path.expanduser(p) for p in a.ionos_config or [IONOS_CONFIG]]

    if a.login:
        for path in ovh_paths:
            ovh_login(path)
        return

    # One account per file, so a domain in a second account is found as well.
    backends = []
    for kind, paths, named in (
        (Ovh, ovh_paths, a.ovh_config is not None),
        (Ionos, ionos_paths, a.ionos_config is not None),
    ):
        missing = [p for p in paths if not os.path.exists(p)]
        if named:
            for path in missing:
                warn(f"{path} does not exist")
        present = [p for p in paths if p not in missing]
        for path in present:
            backend = kind(path, a.apply)
            if len(present) > 1:
                backend.name = f"{backend.name} {os.path.basename(path)}"
            backends.append(backend)
    if not backends:
        fail(f"no credentials: none of {', '.join(ovh_paths + ionos_paths)} exists")

    print("mode:    " + ("APPLY" if a.apply else "dry run (pass --apply to write)"))
    print(f"primary: {a.primary}")
    print()

    if a.domains:
        wanted = [d.rstrip(".").lower() for d in a.domains]
    else:
        wanted = zones(a.host)
        print(f"zones of {a.host}: {', '.join(wanted)}")
        print()

    changed = 0
    skipped = 0
    jobs = max(1, min(a.jobs, len(wanted)))

    if jobs == 1:
        for domain in wanted:
            done, missed = handle(a, backends, domain)
            changed += done
            skipped += missed
            print()
    else:
        # Domains are independent; the registries are the slow part. Each worker
        # keeps its output to itself so the blocks do not interleave.
        sys.stdout = Output(sys.stdout)

        def worker(domain):
            sys.stdout.capture()
            try:
                result = handle(a, backends, domain)
            except SystemExit as e:
                # A refusal from one registrar must not end the whole run.
                print(f"!  {domain}: aborted ({e})")
                result = (0, 1)
            return sys.stdout.release(), result

        with ThreadPoolExecutor(max_workers=jobs) as pool:
            for future in [pool.submit(worker, d) for d in wanted]:
                text, (done, missed) = future.result()
                print(text, end="")
                print()
                changed += done
                skipped += missed

    if skipped:
        print(f"{skipped} domain(s) skipped")

    if not a.apply and changed:
        print(f"{changed} domain(s) would change — rerun with --apply")
    elif a.apply and changed:
        print(f"{changed} domain(s) updated")
        print(f"confirm once it propagates:  dig +trace <domain> {'DS' if a.dnssec else 'NS'}")
    else:
        print("nothing to do")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)
