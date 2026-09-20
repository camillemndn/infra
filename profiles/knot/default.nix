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

  # This machine holds the zones and signs them. It shares its public IPv4
  # with the router, which answers DNS there, so it is a nameserver over
  # IPv6 only.
  nameServers = {
    # SaumonNet router, a secondary configured in saumonnet/infra.
    ns1 = {
      A = [ "77.42.114.11" ];
      AAAA = [ "2a01:4f9:3090:2b8c::2" ];
    };
    ns2.AAAA = [ meta.ipv6.public ];
  };

  # The router pulls the zones over the tailnet, which authenticates its address.
  router = "fd7a:115c:a1e0::1";

  ### Zones from the nginx virtual hosts of every publicly reachable machine

  publicMachines = lib.filterAttrs (_: m: m ? ipv4.public || m ? ipv6.public) machines;

  nginxOf =
    name:
    if name == hostName then
      config.services.nginx
    else
      nixosConfigurations.${name}.config.services.nginx;

  zoneNames = lib.subtractLists foreignZones (
    lib.unique (lib.concatMap (name: (nginxOf name).publicDomains) (lib.attrNames publicMachines))
  );

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
    server.listen = [
      "${meta.ipv6.vpn}@53"
      "${meta.ipv6.public}@53"
    ];

    remote = {
      router.address = router;
      resolver.address = [
        "2606:4700:4700::1111"
        "1.1.1.1"
      ];
    };

    acl.router-transfer = {
      address = router;
      action = "transfer";
    };

    # A new key counts as submitted once the resolver sees its DS at the registry.
    submission.registry.parent = "resolver";

    # One combined signing key per zone, never rolled, so the DS records at
    # the registrars stay valid. Print them with: keymgr <zone> ds
    policy.csk = {
      single-type-signing = true;
      ksk-submission = "registry";
    };

    template.default = {
      semantic-checks = true;
      dnssec-signing = true;
      dnssec-policy = "csk";
      notify = "router";
      acl = "router-transfer";

      # The zone files are in the store: Knot takes the records from them,
      # keeps signatures and the serial in its journal, and never writes back.
      zonefile-sync = -1;
      zonefile-load = "difference-no-serial";
      journal-content = "all";
      serial-policy = "unixtime";
    };

    zone = lib.mapAttrs (name: zone: { file = zoneFile name zone; }) zones;
  };

  # The tailnet address appears after boot.
  boot.kernel.sysctl."net.ipv6.ip_nonlocal_bind" = 1;
  systemd.services.knot.after = [ "tailscaled.service" ];

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
