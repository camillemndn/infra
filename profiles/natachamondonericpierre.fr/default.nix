{
  config,
  lib,
  ...
}:

{
  options.services.nginx.websites."natachamondonericpierre.fr".enable =
    lib.mkEnableOption "Natacha Mondon & Éric Pierre's website.";

  config = lib.mkIf config.services.nginx.websites."natachamondonericpierre.fr".enable {
    services.nginx = {
      publicDomains = [ "www.natachamondonericpierre.mndn.fr" ];

      virtualHosts = {
        "www.natachamondonericpierre.mndn.fr" = {
          root = "/srv/sites/natachamondonericpierre.fr/www";
          locations."/static/".extraConfig = ''
            expires 1y;
            add_header Cache-Control "public";
          '';
          locations."/en/".extraConfig = ''
            error_page 404 /en/404/;
          '';
          extraConfig = ''
            error_page 404 /404/;
            include /srv/sites/natachamondonericpierre.fr/redirect.conf;
          '';
        };

        "natachamondonericpierre.mndn.fr".locations."/".return =
          "301 https://www.natachamondonericpierre.mndn.fr$request_uri";
      };
    };

    security.acme.certs."natachamondonericpierre.mndn.fr".extraDomainNames = [
      "www.natachamondonericpierre.mndn.fr"
    ];
  };
}
