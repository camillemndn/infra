{ config, lib, pkgs, ... }:

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
      package = pkgs.unstable.photoprism;
      originalsPath = "/var/lib/nextcloud/data/Camille/files/Pictures";
      importPath = "";
      passwordFile = "/run/secrets/photos";
      settings = {
        PHOTOPRISM_ADMIN_USER = "camille";
        PHOTOPRISM_READONLY = "true";
        PHOTOPRISM_DISABLE_SETTINGS = "true";
        PHOTOPRISM_DISABLE_WEBDAV = "true";
        PHOTOPRISM_DETECT_NSFW = "true";
        PHOTOPRISM_WORKERS = "12";
        PHOTOPRISM_DATABASE_DRIVER = "mysql";
        PHOTOPRISM_DATABASE_SERVER = "localhost:3306";
        PHOTOPRISM_DATABASE_PASSWORD = "insecure";
      };
    };

    services.nginx.virtualHosts."photos.kms" = { port = 2342; websockets = true; };

    systemd.services.photoprism.serviceConfig.SupplementaryGroups = [ "nextcloud" ];

    systemd.services."photoprism-index" = {
      description = "Photoprism automatic indexer";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/var/lib/photoprism/photoprism-manage index --cleanup";
        KillMode = "process";
      };
    };

    systemd.timers."photoprism-index" = {
      description = "Photoprism automatic indexer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };

    sops.secrets.photos = {
      format = "binary";
      owner = "root";
      sopsFile = ./password;
    };
  };
}
