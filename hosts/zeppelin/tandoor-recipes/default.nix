_:

{
  services = {
    tandoor-recipes = {
      enable = true;
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
