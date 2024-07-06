{ config, lib, ... }:

lib.mkIf config.services.koel.enable {
  services.koel = {
    hostName = "player.kms";
    group = "mediasrv";

    extraConfig.MEDIA_PATH = "/srv/media/Musique";
    secretEnvFile = "/etc/koel/secret-env";
  };

  users.groups.mediasrv = { };
}
