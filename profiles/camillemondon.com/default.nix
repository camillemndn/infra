{
  config,
  lib,
  ...
}:

{
  options.services.nginx.websites."camillemondon.com".enable =
    lib.mkEnableOption "Camille Mondon's website.";

  config = lib.mkIf config.services.nginx.websites."camillemondon.com".enable {
    services.nginx = {
      publicDomains = [
        "camillemondon.com"
        "camillemondon.fr"
      ];

      virtualHosts = {
        "camillemondon.com" = {
          root = "/srv/sites/camillemondon.com/www";
          extraConfig = ''
            rewrite ^([^.]*[^/])$ $1/ permanent;
            error_page 404 /404.html;
          '';
          locations = {
            "/assets/".extraConfig = ''
              expires 1y;
              add_header Cache-Control "public";
            '';
            "/dda/".alias = "/srv/sites/dda/www/";
            "/projects/ot/".alias = "/srv/sites/optimal-transport/www/";
            "/projects/icscoda/".alias = "/srv/sites/icscoda/www/";
            "/projects/plnar/".alias = "/srv/sites/plnar/www/";
            "/projects/random-densities/".alias = "/srv/sites/thesis/www/";
            "/publications/2025/icscomplex/".alias = "/srv/sites/icscomplex/www/";
            "/publications/2025/danova/".alias = "/srv/sites/danova/www/";
            "/publications/2026/icsfobi/".alias = "/srv/sites/icsfobi/www/";
            "/random-densities/".return = "301 https://$server_name/projects$request_uri";
            "/talks/fosdem24-clevis/".alias = "/srv/sites/fosdem24-clevis/www/";
            "/talks/fda/".alias = "/srv/sites/thesis/www/materials/fda/";
            "/talks/jds2024/".alias = "/srv/sites/thesis/www/materials/jds2024/";
            "/talks/codawork2024/".alias = "/srv/sites/thesis/www/materials/codawork2024/";
            "/talks/helsinki2025/".alias = "/srv/sites/thesis/www/materials/helsinki2025/";
            "/talks/helsinki2026/".alias = "/srv/sites/icsfobi/www/slides/";
            "/talks/tse2025/".alias = "/srv/sites/thesis/www/materials/tse2025/";
            "/teaching/hidimdaml".extraConfig = ''
              rewrite ^/teaching/hidimdaml/(.*)$ https://hidimdaml.camillemondon.com/$1 permanent;
            '';
            "/teaching/ics/".alias = "/srv/sites/thesis/www/materials/ics/";
          };
        };
        "www.camillemondon.com".locations."/".return = "301 https://camillemondon.com$request_uri";

        "camillemondon.fr".locations."/".return = "301 https://camillemondon.com$request_uri";

        "hidimdaml.camillemondon.com" = {
          extraConfig = ''
            error_page 404 https://camillemondon.com/404.html;
          '';
          root = "/srv/sites/hidimdaml/www";
          locations."~ solution\\.(html|pdf)".basicAuthFile = "/srv/sites/camillemondon.com_auth";
        };
      };
    };

    security.acme.certs."camillemondon.com".extraDomainNames = [ "www.camillemondon.com" ];
  };
}
