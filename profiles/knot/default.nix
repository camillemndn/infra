{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.knot;
  inherit (config.networking) hostName;
  inherit (import ../..) machines nixosConfigurations;

  dns = import inputs.dns { inherit pkgs; };

  meta = machines.${hostName};

  # Zones of services.nginx.publicDomains whose records live in another repository.
  foreignZones = [ "saumon.network" ];

  # This machine holds the zones and signs them. The delegation names the
  # secondaries below, which transfer from here and answer the public. Moving
  # a role to another machine is a change of addresses here and nowhere else.
  # Both ends of a transfer name the key identically.
  tsigKey = "xfr.mndn.fr.";

  secondaries = {
    # SaumonNet host, configured in saumonnet/infra. It transfers over the
    # tailnet, which authenticates its address.
    ns1 = {
      A = [ "77.42.114.11" ];
      AAAA = [ "2a01:4f9:3090:2b8c::2" ];
      transfer = {
        address = "fd7a:115c:a1e0::2";
        via = meta.ipv6.vpn;
      };
    };

    # Off the tailnet, so its transfers cross the internet under a TSIG key.
    ns2 = {
      A = [ machines.offspring.ipv4.public ];
      AAAA = [ machines.offspring.ipv6.public ];
      transfer = {
        # Privacy extensions would otherwise send the notify from a temporary
        # address, which the secondary does not know.
        address = machines.offspring.ipv6.public;
        key = tsigKey;
        via = meta.ipv6.public;
      };
    };
  };

  nameServers = lib.mapAttrs (_: ns: builtins.removeAttrs ns [ "transfer" ]) secondaries;

  ### Zones from the nginx virtual hosts of every publicly reachable machine

  dnsZones = lib.dnsZones {
    inherit
      config
      hostName
      machines
      nixosConfigurations
      foreignZones
      ;
  };

  inherit (dnsZones) publicMachines nginxOf;

  zoneNames = dnsZones.names;

  ### The tailnet zone, which this machine also holds

  vpnTld = "kms";

  # Who may ask for it: the tailnet and the home network, nobody else.
  vpnRanges = [
    "100.100.45.0/24"
    "fd7a:115c:a1e0::/48"
    "192.168.0.0/21"
    "fde7:d935:2cb6:f86c::/64"
  ];

  vpnMachines = lib.filterAttrs (_: m: m ? ipv4.vpn || m ? ipv6.vpn) machines;

  vpnAddresses =
    m:
    lib.filterAttrs (_: v: v != [ ]) {
      A = lib.optional (m ? ipv4.vpn) m.ipv4.vpn;
      AAAA = lib.optional (m ? ipv6.vpn) m.ipv6.vpn;
    };

  # The machine itself, plus every virtual host it serves over the tailnet.
  vpnNames =
    name: m:
    [ name ]
    ++ lib.optionals (nginxOf name).enable (
      map (lib.removeSuffix ".${vpnTld}") (
        lib.filter (lib.hasSuffix ".${vpnTld}") (lib.attrNames (nginxOf name).virtualHosts)
      )
    );

  vpnZone = {
    TTL = 60 * 60;
    SOA = {
      nameServer = "ns1";
      adminEmail = "hostmaster@${vpnTld}";
      serial = 1;
      refresh = 4 * 60 * 60;
      retry = 60 * 60;
      expire = 14 * 24 * 60 * 60;
      minimum = 60 * 60;
    };
    NS = [ "ns1" ];
    subdomains = {
      ns1 = vpnAddresses meta;
    }
    // lib.foldl lib.recursiveUpdate { } (
      lib.concatLists (
        lib.mapAttrsToList (name: m: map (n: { ${n} = vpnAddresses m; }) (vpnNames name m)) vpnMachines
      )
    );
  };

  zoneOf =
    name:
    let
      matches = lib.filter (zone: name == zone || lib.hasSuffix ".${zone}" name) zoneNames;
    in
    if matches == [ ] then
      null
    else
      lib.last (lib.sort (a: b: lib.stringLength a < lib.stringLength b) matches);

  addresses =
    m:
    lib.filterAttrs (_: v: v != [ ]) {
      A = lib.optional (m ? ipv4.public) m.ipv4.public;
      AAAA = lib.optional (m ? ipv6.public) m.ipv6.public;
    };

  namesOf =
    name: m:
    lib.optionals (nginxOf name).enable (lib.attrNames (nginxOf name).virtualHosts)
    ++ [ "${name}.${m.tld}" ];

  hostRecords = lib.concatLists (
    lib.mapAttrsToList (
      machine: m:
      lib.concatMap (
        name:
        let
          zone = zoneOf name;
        in
        lib.optional (zone != null) {
          ${zone} =
            if name == zone then
              addresses m
            else
              { subdomains.${lib.removeSuffix ".${zone}" name} = addresses m; };
        }
      ) (namesOf machine m)
    ) publicMachines
  );

  zones = lib.genAttrs zoneNames (
    zone:
    lib.foldl lib.recursiveUpdate
      {
        TTL = 60 * 60;
        SOA = {
          nameServer = "ns1";
          adminEmail = "hostmaster@${zone}";
          # Knot keeps the real serial and ignores this one.
          serial = 1;
          refresh = 4 * 60 * 60;
          retry = 60 * 60;
          expire = 14 * 24 * 60 * 60;
          minimum = 60 * 60;
        };
        NS = lib.attrNames nameServers;
        subdomains = nameServers;
      }
      (
        map (r: r.${zone} or { }) hostRecords
        ++ [ ((import ./records.nix { inherit machines; }).${zone} or { }) ]
      )
  );

  # Checked at build time, so a bad record fails the deployment, not the server.
  zoneFile =
    name: zone:
    pkgs.runCommand "${name}.zone"
      {
        nativeBuildInputs = [ cfg.package ];
        text = dns.lib.toString name zone;
        passAsFile = [ "text" ];
      }
      ''
        kzonecheck -o ${name} "$textPath"
        cp "$textPath" $out
      '';
in

lib.mkIf cfg.enable {
  services.knot.settings = {
    server = {
      listen = [
        "${meta.ipv6.vpn}@53"
        "${meta.ipv6.public}@53"
      ];

      # A scanner learns which advisories to try from the version string.
      version = "none";
    };

    remote = lib.mapAttrs (_: ns: ns.transfer) secondaries // {
      resolver.address = [
        "2606:4700:4700::1111"
        "1.1.1.1"
      ];
    };

    acl = lib.mapAttrs' (
      name: ns:
      lib.nameValuePair "${name}-transfer" (
        builtins.removeAttrs ns.transfer [ "via" ] // { action = "transfer"; }
      )
    ) secondaries;

    # An ACL cannot keep a zone private: a plain query needs no authorisation
    # and is always answered. This module is what turns the others away, with
    # NOTAUTH.
    mod-queryacl.internal.address = vpnRanges;

    # A new key counts as submitted once the resolver sees its DS at the registry.
    submission.registry.parent = "resolver";

    # One combined signing key per zone, never rolled, so the DS records at
    # the registrars stay valid. Print them with: keymgr <zone> ds
    policy.csk = {
      single-type-signing = true;
      ksk-submission = "registry";

      # NSEC lets anyone read the zone back name by name; NSEC3 publishes
      # hashes instead. Iterations stay at 0, as RFC 9276 asks.
      nsec3 = true;
      nsec3-iterations = 0;
    };

    template = {
      default = {
        semantic-checks = true;
        dnssec-signing = true;
        dnssec-policy = "csk";
        notify = lib.attrNames secondaries;
        acl = map (name: "${name}-transfer") (lib.attrNames secondaries);

        # The zone files are in the store: Knot takes the records from them,
        # keeps signatures and the serial in its journal, and never writes back.
        zonefile-sync = -1;
        zonefile-load = "difference-no-serial";
        journal-content = "all";
        serial-policy = "unixtime";
      };

      # The tailnet zone has no parent to publish a DS, and no secondary: the
      # resolver on the gateway forwards to this machine for it.
      internal = {
        semantic-checks = true;
        module = "mod-queryacl/internal";
        zonefile-sync = -1;
        zonefile-load = "difference-no-serial";
        journal-content = "all";
        serial-policy = "unixtime";
      };
    };

    zone = lib.mapAttrs (name: zone: { file = zoneFile name zone; }) zones // {
      ${vpnTld} = {
        file = zoneFile vpnTld vpnZone;
        template = "internal";
      };
    };
  };

  # The TSIG secret would be world-readable in the store, so knotd includes it
  # from a file at runtime instead.
  services.knot.keyFiles = [ config.age.secrets.knot-tsig.path ];

  age.secrets.knot-tsig = {
    file = ./tsig.age;
    owner = "knot";
  };

  # The tailnet address appears after boot.
  boot.kernel.sysctl."net.ipv6.ip_nonlocal_bind" = 1;
  systemd.services.knot.after = [ "tailscaled.service" ];

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
