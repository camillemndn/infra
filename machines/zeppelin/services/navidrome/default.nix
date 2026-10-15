{
  config,
  lib,
  ...
}:

lib.mkIf config.services.navidrome.enable {
  services = {
    navidrome = {
      group = "media";
      settings.MusicFolder = "/srv/media/Musique";
    };

    nginx.virtualHosts."music.mndn.fr".port = config.services.navidrome.settings.Port;
  };
}
