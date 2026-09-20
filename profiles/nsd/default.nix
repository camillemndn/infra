{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nsd;
  inherit (config.networking) hostName;
  inherit (import ../..) machines nixosConfigurations;

  dns = import inputs.dns { inherit pkgs; };
  stateDir = "/var/lib/nsd";

  meta = machines.${hostName};

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

  # Where NOTIFY goes and who may transfer: "<address> <TSIG key | NOKEY>".
  # The router is reached over the tailnet, which authenticates its address.
  secondaries = [ "fd7a:115c:a1e0::1 NOKEY" ];

  ### Zones from the nginx virtual hosts of every publicly reachable machine

  publicMachines = lib.filterAttrs (_: m: m ? ipv4.public || m ? ipv6.public) machines;

  nginxOf =
    name:
    if name == hostName then
      config.services.nginx
    else
      nixosConfigurations.${name}.config.services.nginx;

  # services.nginx.publicDomains lists the domains served to the internet,
  # which are the zones to be authoritative for.
  zoneNames = lib.unique (
    lib.concatMap (name: (nginxOf name).publicDomains) (lib.attrNames publicMachines)
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
          # Replaced by the signing time whenever the zone is signed.
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

  ### DNSSEC

  # One combined signing key per zone, created on first start and kept in
  # ${stateDir}/dnssec. Signing stamps the SOA serial with the current time,
  # so every deployment and every re-signing reaches the secondaries.
  signZones = pkgs.writeShellScript "nsd-sign-zones" ''
    set -eu
    export PATH=${
      lib.makeBinPath [
        pkgs.bind
        pkgs.coreutils
      ]
    }
    keys=${stateDir}/dnssec
    install -d -m 0700 "$keys"
    cd "$keys"

    for zone in ${lib.escapeShellArgs zoneNames}; do
      if ! ls "K$zone."*.key > /dev/null 2>&1; then
        dnssec-keygen -K "$keys" -a ECDSAP256SHA256 -f KSK "$zone"
      fi
      dnssec-signzone -K "$keys" -d "$keys" -S -z -N unixtime -o "$zone" \
        -f "${stateDir}/zones/$zone.signed" "${stateDir}/zones/$zone"
      mv "${stateDir}/zones/$zone.signed" "${stateDir}/zones/$zone"
      # The DS records to publish at the registrar.
      dnssec-dsfromkey -2 "K$zone."*.key > "$keys/$zone.ds"
    done
  '';
in

lib.mkIf cfg.enable {
  services.nsd = {
    # The tailnet address appears after boot.
    ipFreebind = true;
    interfaces = [
      meta.ipv6.vpn
      meta.ipv6.public
    ];

    zones = lib.mapAttrs (name: zone: {
      data = dns.lib.toString name zone;
      notify = secondaries;
      provideXFR = secondaries;
    }) zones;
  };

  systemd.services.nsd = {
    after = [ "tailscaled.service" ];
    # Runs after the module's preStart has copied the unsigned zones.
    serviceConfig.ExecStartPre = lib.mkAfter [ signZones ];
  };

  # Signatures last 30 days; a restart signs again.
  systemd.services.nsd-resign = {
    description = "Re-sign the NSD zones";
    startAt = "weekly";
    serviceConfig.Type = "oneshot";
    script = "systemctl restart nsd.service";
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
