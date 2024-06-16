{
  config,
  lib,
  pkgs,
  ...
}:

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
        PHOTOPRISM_DATABASE_DRIVER = "mysql";
        PHOTOPRISM_DATABASE_PASSWORD = "insecure";
        PHOTOPRISM_DATABASE_SERVER = "localhost:3306";
        PHOTOPRISM_DETECT_NSFW = "true";
        PHOTOPRISM_DISABLE_WEBDAV = "true";
        PHOTOPRISM_READONLY = "true";
        PHOTOPRISM_THUMB_UNCACHED = "true";
        PHOTOPRISM_WORKERS = "12";
      };
    };

    services.nginx.virtualHosts."photos.kms" = {
      port = 2342;
      websockets = true;
    };

    systemd.services.photoprism.serviceConfig.SupplementaryGroups = [ "nextcloud" ];

    systemd.services.photoprism-index = {
      description = "Photoprism automatic indexer";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = config.systemd.services.photoprism.serviceConfig // {
        Type = "oneshot";
        ExecStartPre = null;
        ExecStart = "${pkgs.photoprism}/bin/photoprism index --cleanup";
        ExecStartPost = "${pkgs.photoprism}/bin/photoprism thumbs";
        KillMode = "process";
      };
      inherit (config.systemd.services.photoprism) environment;
    };

    systemd.timers.photoprism-index = {
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
