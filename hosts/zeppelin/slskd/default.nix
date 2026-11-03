{ config, ... }:

let
  downloads = "/srv/media/Téléchargements/slskd";
in

{
  # SLSKD_SLSK_USERNAME, SLSKD_SLSK_PASSWORD, SLSKD_USERNAME, SLSKD_PASSWORD
  age.secrets.slskd.file = ./env.age;

  services = {
    slskd = {
      enable = true;
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

  systemd = {
    services.slskd = {
      # .NET keeps named mutexes here, or else under the passwd home, which is /var/empty.
      environment.XDG_RUNTIME_DIR = "/run/slskd";

      serviceConfig = {
        RuntimeDirectory = "slskd";
        RuntimeDirectoryMode = "0700";
        UMask = "0002";
      };
    };

    tmpfiles.rules = [ "d '${downloads}' 0775 slskd media -" ];
  };
}
