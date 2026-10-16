_:

{
  services.nginx = {
    publicDomains = [ "yali.es" ];

    virtualHosts."yali.es" = {
      root = "/srv/sites/yali.es/www";

      locations = {
        "/static/".extraConfig = ''
          expires 1y;
          add_header cache-control "public";
        '';
        "/es/".extraConfig = ''
          error_page 404 /es/404/;
        '';
      };

      extraConfig = ''
        error_page 404 /fr/404/;
      '';
    };
  };
}
