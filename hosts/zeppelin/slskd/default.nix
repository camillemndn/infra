{ config, ... }:

let
  downloads = "/srv/media/Téléchargements/slskd";
in

{
  # SLSKD_SLSK_USERNAME, SLSKD_SLSK_PASSWORD, SLSKD_USERNAME, SLSKD_PASSWORD
  age.secrets.slskd.file = ./env.age;

  services = {
    nginx.virtualHosts."soulseek.kms" = {
      port = 5030;
      websockets = true;
    };

    slskd = {
      enable = true;
      domain = null;
      environmentFile = config.age.secrets.slskd.path;
      group = "media";

      settings = {
        directories.downloads = downloads;
        shares.directories = [ ];
      };
    };
  };

  systemd = {
    services.slskd.serviceConfig.UMask = "0002";
    tmpfiles.rules = [ "d '${downloads}' 0775 slskd media -" ];
  };
}
