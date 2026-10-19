_:

{
  security.acme.certs."natachamondonericpierre.mndn.fr".extraDomainNames = [
    "www.natachamondonericpierre.mndn.fr"
  ];

  services.nginx = {
    publicDomains = [ "mndn.fr" ];

    virtualHosts = {
      "natachamondonericpierre.mndn.fr".locations."/".return =
        "301 https://www.natachamondonericpierre.mndn.fr$request_uri";

      "www.natachamondonericpierre.mndn.fr" = {
        extraConfig = ''
          error_page 404 /404/;
          include /srv/sites/natachamondonericpierre.fr/redirect.conf;
        '';

        locations = {
          "/en/".extraConfig = ''
            error_page 404 /en/404/;
          '';

          "/static/".extraConfig = ''
            expires 1y;
            add_header Cache-Control "public";
          '';
        };

        root = "/srv/sites/natachamondonericpierre.fr/www";
      };
    };
  };
}
