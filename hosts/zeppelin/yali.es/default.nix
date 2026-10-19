_:

{
  services.nginx = {
    publicDomains = [ "yali.es" ];

    virtualHosts."yali.es" = {
      extraConfig = ''
        error_page 404 /fr/404/;
      '';

      locations = {
        "/es/".extraConfig = ''
          error_page 404 /es/404/;
        '';

        "/static/".extraConfig = ''
          expires 1y;
          add_header cache-control "public";
        '';
      };

      root = "/srv/sites/yali.es/www";
    };
  };
}
