{
  config,
  pkgs,
  ...
}:

{
  age.secrets.photoprism-password.file = ./password.age;
  environment.systemPackages = [ pkgs.photoprism ];

  services = {
    nginx.virtualHosts."photos.kms" = {
      port = 2342;
      websockets = true;
    };

    photoprism = {
      enable = true;
      importPath = "";
      originalsPath = "/var/lib/nextcloud/data/Camille/files/Images";
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
  };

  systemd = {
    services = {
      photoprism-index = {
        inherit (config.systemd.services.photoprism) environment;
        after = [ "multi-user.target" ];
        description = "Photoprism automatic indexer";

        serviceConfig = config.systemd.services.photoprism.serviceConfig // {
          ExecStart = "${pkgs.photoprism}/bin/photoprism index --cleanup";
          ExecStartPre = null;
          KillMode = "process";
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      };

      photoprism.serviceConfig.SupplementaryGroups = [ "nextcloud" ];
    };

    timers.photoprism-index = {
      description = "Photoprism automatic indexer";

      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };
  };
}
