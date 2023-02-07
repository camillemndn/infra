{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.websites;
in
with lib;

{
  options.profiles.websites = {
    enable = mkEnableOption "Activate my virtual hosts";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nginx = {
      enable = true;

      recommendedProxySettings = true;

      virtualHosts."camille.mondon.me" = {
        enableACME = true;
        forceSSL = true;
        root = "/srv/sites/camille-www";
        default = true;
        locations."/".extraConfig = ''
          add_header 'Access-Control-Allow-Origin' 'http://home.kms';
          add_header 'Access-Control-Allow-Credentials' true;
          allow 100.10.10.0/8;
          deny all;
        '';
      };

      virtualHosts."yali.es".root = "/srv/sites/yali-www";
    };
  };
}
