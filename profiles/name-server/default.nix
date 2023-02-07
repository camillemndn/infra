{ config, lib, ... }:

let
  cfg = config.profiles.name-server;
in
with lib;

{
  options.profiles.name-server = {
    enable = mkEnableOption "Unbound DNS server";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "::1"
            "10.101.0.2"
          ];
          access-control = [
            "127.0.0.0/8 allow"
            "::1/128 allow"
            "10.101.0.0/24 allow"
            "fd42::/16 allow"
          ];
          #private-address = [
          # "fd42::/16" "10.42.0.0/16"
          #];
          local-zone = [
            ''"mondon.me" redirect''
            ''"_dmarc.mondon.me" transparent''
            ''"luj" transparent''
          ];
          local-data = [
            ''"mondon.me. A 0.0.0.0"''
          ];
        };
        forward-zone = [{
          name = ".";
          forward-addr = [ "9.9.9.9" ];
        }];
      };
    };
  };
}
