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

  meta = machines.${hostName};

  # Zones of services.nginx.publicDomains whose records live in another repository.
  foreignZones = [ "saumon.network" ];

  # This machine answers for zones held and signed elsewhere. Transfers cross
  # the internet, so they carry a TSIG key.
  primary = "zeppelin";
  primaryAddress = machines.${primary}.ipv6.public;
  # Both ends of a transfer name the key identically.
  tsigKey = "xfr.mndn.fr.";

  zoneNames =
    (lib.dnsZones {
      inherit
        config
        hostName
        machines
        nixosConfigurations
        foreignZones
        ;
    }).names;

  # A zone needs a file before its first transfer; the transfer replaces it.
  emptyZone = name: {
    SOA = {
      nameServer = "ns1";
      adminEmail = "hostmaster@${name}";
      serial = 0;
    };
  };
in

lib.mkIf cfg.enable {
  services.nsd = {
    # The public IPv4 is a NAT address of the cloud provider and never appears
    # on the interface, so NSD binds the address behind it.
    interfaces = [
      meta.ipv4.local
      meta.ipv6.public
    ];

    keys.${tsigKey} = {
      algorithm = "hmac-sha256";
      keyFile = config.age.secrets.nsd-tsig.path;
    };

    zones = lib.genAttrs zoneNames (name: {
      data = dns.lib.toString name (emptyZone name);
      requestXFR = [ "AXFR ${primaryAddress} ${tsigKey}" ];
      allowNotify = [ "${primaryAddress} ${tsigKey}" ];
    });
  };

  age.secrets.nsd-tsig.file = ./tsig.age;

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
