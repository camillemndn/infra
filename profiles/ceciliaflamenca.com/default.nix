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
        locations."/images/".extraConfig = ''
          expires 1y;
          add_header cache-control "public";
        '';
      };
    };
  };
}
