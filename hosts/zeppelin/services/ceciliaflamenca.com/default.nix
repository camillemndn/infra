{
  config,
  lib,
  ...
}:

{
  options.services.nginx.websites."ceciliaflamenca.com".enable =
    lib.mkEnableOption "Cecilia flamenca's website.";

  config = lib.mkIf config.services.nginx.websites."ceciliaflamenca.com".enable {
    services.nginx = {
      publicDomains = [ "ceciliaflamenca.com" ];

      virtualHosts."ceciliaflamenca.com" = {
        root = "/srv/sites/ceciliaflamenca.com/www";
        locations."/static/".extraConfig = ''
          expires 1y;
          add_header Cache-Control "public";
        '';
        locations."/es/".extraConfig = ''
          error_page 404 /es/404/;
        '';
        extraConfig = ''
          error_page 404 /fr/404/;
        '';
      };
    };
  };
}
