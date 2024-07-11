{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.photoprism.enable {
  services = {
    photoprism = {
      package = pkgs.photoprism;
      originalsPath = "/var/lib/nextcloud/data/Camille/files/Pictures";
      importPath = "";
      passwordFile = config.age.secrets.photoprism-password.path;
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

    nginx.virtualHosts."photos.kms" = {
      port = 2342;
      websockets = true;
    };
  };

  systemd = {
    services = {
      photoprism.serviceConfig.SupplementaryGroups = [ "nextcloud" ];

      photoprism-index = {
        description = "Photoprism automatic indexer";
        after = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = config.systemd.services.photoprism.serviceConfig // {
          Type = "oneshot";
          ExecStartPre = null;
          ExecStart = "${pkgs.photoprism}/bin/photoprism index --cleanup";
          KillMode = "process";
        };
        inherit (config.systemd.services.photoprism) environment;
      };
    };

    timers.photoprism-index = {
      description = "Photoprism automatic indexer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };

  age.secrets.photoprism-password.file = ./password.age;
}
