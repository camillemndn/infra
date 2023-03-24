{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.radiogaga;
in
with lib;

{
  options.profiles.radiogaga = {
    enable = mkEnableOption "Activate my radio alarm clock";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 8000 ];

    services.piclodio3.enable = true;

    services.nginx = {
      enable = true;

      recommendedProxySettings = true;

      virtualHosts."radiogaga.local" = {
        #forceSSL = true;
        #sslCertificateKey = "/etc/ssl/certs/radiogaga-local-key.pem";
        #sslCertificate = "/etc/ssl/certs/radiogaga-local.pem";
        root = "${pkgs.piclodio3}/share/piclodio3-front";
        default = true;
        locations."/".extraConfig = ''
          try_files $uri $uri/ /index.html =404;
        '';
      };
    };
  };
}
