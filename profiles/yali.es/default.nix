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
        locations."/images/".extraConfig = ''
          expires 1y;
          add_header cache-control "public";
        '';
      };
    };
  };
}
