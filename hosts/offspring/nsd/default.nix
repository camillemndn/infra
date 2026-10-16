{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.networking) hostName;
  inherit (import ../../..) nixosConfigurations;
  machines = lib.mapAttrs (_: c: c.config.networking.addresses) nixosConfigurations;

  dns = import inputs.dns { inherit pkgs; };

  meta = config.networking.addresses;

  # Secondary for zones signed elsewhere; transfers cross the internet under a TSIG key.
  primary = "zeppelin";
  primaryAddress = machines.${primary}.ipv6.public;
  # Notifies may come from any address of the primary; the key authenticates them.
  primaryPrefix = "${lib.concatStringsSep ":" (lib.take 4 (lib.splitString ":" primaryAddress))}::/64";
  # Same key name on both ends.
  tsigKey = "xfr.mndn.fr.";

  zoneNames =
    (lib.dnsZones {
      inherit
        config
        hostName
        machines
        nixosConfigurations
        ;
    }).names;

  # Placeholder until the first transfer.
  emptyZone = name: {
    SOA = {
      nameServer = "ns1";
      adminEmail = "hostmaster@${name}";
      serial = 0;
    };
  };
in

{
  services = {
    nsd = {
      enable = true;
      # The public IPv4 is NAT: bind the address behind it.
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
        allowNotify = [ "${primaryPrefix} ${tsigKey}" ];
      });
    };
  };

  age.secrets.nsd-tsig.file = ./tsig.age;

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
