_:

{
  services = {
    nginx.virtualHosts."meals.mndn.fr".port = 8180;

    tandoor-recipes = {
      enable = true;

      extraConfig = {
        ALLOWED_HOSTS = [ "meals.mndn.fr" ];
        GUNICORN_MEDIA = "1";
        MEDIA_ROOT = "/var/lib/tandoor-recipes/media";
      };

      port = 8180;
    };
  };
}
