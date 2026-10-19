_:

{
  services.nginx = {
    publicDomains = [ "ceciliaflamenca.com" ];

    virtualHosts."ceciliaflamenca.com" = {
      extraConfig = ''
        error_page 404 /fr/404/;
      '';

      locations = {
        "/es/".extraConfig = ''
          error_page 404 /es/404/;
        '';

        "/static/".extraConfig = ''
          expires 1y;
          add_header Cache-Control "public";
        '';
      };

      root = "/srv/sites/ceciliaflamenca.com/www";
    };
  };
}
