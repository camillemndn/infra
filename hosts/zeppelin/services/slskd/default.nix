{ config, lib, ... }:

let
  downloads = "/srv/media/Téléchargements/slskd";
in

lib.mkIf config.services.slskd.enable {
  services = {
    slskd = {
      group = "media";
      domain = null;
      environmentFile = config.age.secrets.slskd.path;
      settings = {
        shares.directories = [ ];
        directories.downloads = downloads;
      };
    };
    nginx.virtualHosts."soulseek.kms" = {
      port = 5030;
      websockets = true;
    };
  };

  systemd.services.slskd.serviceConfig.UMask = "0002";

  systemd.tmpfiles.rules = [ "d '${downloads}' 0775 slskd media -" ];

  # SLSKD_SLSK_USERNAME, SLSKD_SLSK_PASSWORD, SLSKD_USERNAME, SLSKD_PASSWORD
  age.secrets.slskd.file = ./env.age;
}
