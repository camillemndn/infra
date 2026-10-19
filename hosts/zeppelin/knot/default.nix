{
  config,
  hosts,
  inputs,
  lib,
  nixosConfigurations,
  pkgs,
  ...
}:

let
  cfg = config.services.knot;
  dns = import inputs.dns { inherit pkgs; };
  meta = config.networking.addresses;
  # Primary: signs the zones; the secondaries below transfer from here and
  # answer the public. Both ends name the TSIG key identically.
  tsigKey = "xfr.mndn.fr.";

  secondaries = {
    # SaumonNet host (saumonnet/infra), transferring over the tailnet.
    ns1 = {
      A = [ "77.42.114.11" ];
      AAAA = [ "2a01:4f9:3090:2b8c::2" ];

      transfer = {
        address = "fd7a:115c:a1e0::2";
        via = meta.ipv6.vpn;
      };
    };

    # Off the tailnet: transfers use the TSIG key.
    ns2 = {
      A = [ hosts.offspring.ipv4.public ];
      AAAA = [ hosts.offspring.ipv6.public ];

      transfer = {
        # Fixed source: privacy extensions would pick an address the secondary doesn't know.
        address = hosts.offspring.ipv6.public;
        key = tsigKey;
        via = meta.ipv6.public;
      };
    };
  };

  nameServers = lib.mapAttrs (_: ns: builtins.removeAttrs ns [ "transfer" ]) secondaries;

  # ## Public zones

  dnsZones = lib.dnsZones {
    inherit
      config
      hosts
      nixosConfigurations
      ;
  };

  inherit (dnsZones) publicMachines nginxOf configOf;
  zoneNames = dnsZones.names;
  # ## Tailnet zone

  vpnTld = "kms";

  # Tailnet and home network only.
  vpnRanges = [
    "100.100.45.0/24"
    "fd7a:115c:a1e0::/48"
    "192.168.0.0/21"
    "fde7:d935:2cb6:f86c::/64"
  ];

  vpnMachines = lib.filterAttrs (_: m: m ? ipv4.vpn || m ? ipv6.vpn) hosts;

  vpnAddresses =
    m:
    lib.filterAttrs (_: v: v != [ ]) {
      A = lib.optional (m ? ipv4.vpn) m.ipv4.vpn;
      AAAA = lib.optional (m ? ipv6.vpn) m.ipv6.vpn;
    };

  # The machine and its tailnet virtual hosts.
  vpnNames =
    name:
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
        lib.mapAttrsToList (name: m: map (n: { ${n} = vpnAddresses m; }) (vpnNames name)) vpnMachines
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

  domainOf = name: (configOf name).networking.domain;

  namesOf =
    name:
    lib.optionals (nginxOf name).enable (lib.attrNames (nginxOf name).virtualHosts)
    ++ lib.optional (domainOf name != null) "${name}.${domainOf name}";

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
      ) (namesOf machine)
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
        ++ [ ((import ./records.nix { inherit hosts; }).${zone} or { }) ]
      )
  );

  # Checked at build time: bad records fail the deployment.
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

{
  services = {
    knot = {
      enable = true;

      settings = {
        server = {
          listen = [
            "${meta.ipv6.vpn}@53"
            "${meta.ipv6.public}@53"
          ];

          # Hidden from scanners.
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

        # Plain queries ignore ACLs; this module answers outsiders NOTAUTH.
        mod-queryacl.internal.address = vpnRanges;
        # Submitted once the resolver sees the DS at the registry.
        submission.registry.parent = "resolver";

        # One CSK per zone, never rolled, so registrar DS records stay valid (keymgr <zone> ds).
        policy.csk = {
          single-type-signing = true;
          ksk-submission = "registry";
          # NSEC3 against zone walking, 0 iterations (RFC 9276).
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
            # Zone files live in the store; signatures and serial stay in the journal.
            zonefile-sync = -1;
            zonefile-load = "difference-no-serial";
            journal-content = "all";
            serial-policy = "unixtime";
          };

          # No parent DS and no secondary: the gateway's resolver forwards here.
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

      # Read at runtime, keeping the TSIG secret out of the store.
      keyFiles = [ config.age.secrets.knot-tsig.path ];
    };
  };

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
