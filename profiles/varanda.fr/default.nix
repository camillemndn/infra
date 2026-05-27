{
  config,
  lib,
  ...
}:

{
  options.services.nginx.websites."varanda.fr".enable = lib.mkEnableOption "Varanda's website.";

  config = lib.mkIf config.services.nginx.websites."varanda.fr".enable {
    services.nginx = {
      publicDomains = [ "varanda.fr" ];

      virtualHosts = {
        "varanda.fr" = {
          root = "/srv/sites/varanda.fr/www";
          locations."/static/".extraConfig = ''
            expires 1y;
            add_header Cache-Control "public";
          '';
          extraConfig = ''
            error_page 404 /404/;
          '';
        };

        "www.varanda.fr".locations."/".return = "301 https://varanda.fr$request_uri";
      };
    };

    security.acme.certs."varanda.fr".extraDomainNames = [ "www.varanda.fr" ];
  };
}
