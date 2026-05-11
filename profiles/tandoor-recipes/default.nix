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
        ALLOWED_HOSTS = [ "meals.mondon.xyz" ];
        GUNICORN_MEDIA = "1";
        MEDIA_ROOT = "/var/lib/tandoor-recipes/media";
      };
    };

    nginx.virtualHosts."meals.mondon.xyz".port = 8180;
  };
}
