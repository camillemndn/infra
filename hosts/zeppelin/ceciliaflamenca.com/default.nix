_:

{

  services.nginx = {
    publicDomains = [ "ceciliaflamenca.com" ];

    virtualHosts."ceciliaflamenca.com" = {
      root = "/srv/sites/ceciliaflamenca.com/www";
      locations = {
        "/static/".extraConfig = ''
          expires 1y;
          add_header Cache-Control "public";
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
