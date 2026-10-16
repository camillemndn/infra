{
  config,
  lib,
  ...
}:

lib.mkIf config.services.tandoor-recipes.enable {
  services = {
    tandoor-recipes = {
      port = 8180;
      extraConfig = {
        ALLOWED_HOSTS = [ "meals.mndn.fr" ];
        GUNICORN_MEDIA = "1";
        MEDIA_ROOT = "/var/lib/tandoor-recipes/media";
      };
    };

    nginx.virtualHosts."meals.mndn.fr".port = 8180;
  };
}
