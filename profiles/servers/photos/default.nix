{ config, lib, ... }:

let
  cfg = config.profiles.photos;
in
with lib;

{
  options.profiles.photos = {
    enable = mkEnableOption "Photos";
  };

  config = mkIf cfg.enable {
    services.photoprism = {
      enable = true;
      originalsPath = "/var/lib/nextcloud/data/Camille/files/Pictures";
      importPath = "/var/lib/nextcloud/data/Camille/files/Pictures";
      passwordFile = "/run/secrets/photos";
      settings.PHOTOPRISM_ADMIN_USER = "camille";
    };

    services.nginx.virtualHosts."photos.kms" = { port = 2342; websockets = true; };

    systemd.services.photoprism.serviceConfig.SupplementaryGroups = [ "nextcloud" ];

    systemd.services."photoprism-index" = {
      description = "Photoprism automatic indexer";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "/var/lib/photoprism/photoprism-manage index --cleanup";
        KillMode = "process";
        Restart = "always";
      };
    };

    sops.secrets.photos = {
      format = "binary";
      owner = "root";
      sopsFile = ./password;
    };
  };
}
