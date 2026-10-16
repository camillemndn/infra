{
  config,
  ...
}:

{
  services = {
    navidrome = {
      enable = true;
      group = "media";
      settings.MusicFolder = "/srv/media/Musique";
    };
    nginx.virtualHosts."music.mndn.fr".port = config.services.navidrome.settings.Port;
  };
}
