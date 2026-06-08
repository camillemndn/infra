{
  config,
  lib,
  ...
}:

{
  options.services.nginx.websites."yali.es".enable = lib.mkEnableOption "Yali's website.";

  config = lib.mkIf config.services.nginx.websites."yali.es".enable {
    services.nginx = {
      publicDomains = [ "yali.es" ];

      virtualHosts."yali.es" = {
        root = "/srv/sites/yali.es/www";
        locations."/static/".extraConfig = ''
          expires 1y;
          add_header cache-control "public";
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
