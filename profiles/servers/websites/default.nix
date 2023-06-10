{ config, lib, ... }:

let
  cfg = config.profiles.websites;
in
with lib;

{
  options.profiles.websites = {
    enable = mkEnableOption "Activate my virtual hosts";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 443 ];

    services.nginx = {
      enable = true;
      serverNamesHashBucketSize = 64;
      serverNamesHashMaxSize = 512;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      # virtualHosts."camille.mondon.me" = {
      #   forceSSL = true;
      #   enableACME = true;
      #   root = "/srv/sites/camille-www";
      #   locations."/".extraConfig = ''
      #     add_header 'Access-Control-Allow-Origin' 'http://home.kms';
      #     add_header 'Access-Control-Allow-Credentials' true;
      #     allow 100.10.10.0/8;
      #     deny all;
      #   '';
      # };

      virtualHosts.default = {
        default = true;
        addSSL = true;
        sslCertificate = "/var/lib/acme/default/cert.pem";
        sslCertificateKey = "/var/lib/acme/default/key.pem";
        extraConfig = ''
          return 444;
        '';
      };

      virtualHosts."yali.es" = {
        forceSSL = true;
        enableACME = true;
        root = "/srv/sites/yali-www";
      };
    };
  };
}
