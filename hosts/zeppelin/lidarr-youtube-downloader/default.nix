{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.lidarr-youtube-downloader;
in
with lib;

{
  options.services.lidarr-youtube-downloader = {
    enable = mkEnableOption "Lidarr YouTube Downloader";

    downloadPath = mkOption {
      default = null;

      description = ''
        Directory downloads are written to. Must be writable by the service
        user (see {option}`services.lidarr-youtube-downloader.group`).
      '';

      example = "/data/downloads";
      type = types.nullOr types.path;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path to an EnvironmentFile holding secrets such as `LIDARR_API_KEY`
        and `ACOUSTID_API_KEY`. Keeps them out of the world-readable Nix store.
        All other settings can also be configured from the web UI, which
        persists them to `/config/config.json` in the state directory.
      '';

      example = "/run/secrets/lidarr-youtube-downloader.env";
      type = types.nullOr types.path;
    };

    extraEnvironment = mkOption {
      default = { };
      description = "Extra environment variables passed to the service.";

      example = {
        SCHEDULER_ENABLED = "true";
        SCHEDULER_INTERVAL = "120";
      };

      type = types.attrsOf types.str;
    };

    group = mkOption {
      default = "lidarr-youtube-downloader";

      description = ''
        Group the service runs as. Set this to a shared media group so the
        service can write to the download and music directories.
      '';

      type = types.str;
    };

    host = mkOption {
      default = "127.0.0.1";
      description = "Address the web UI binds to.";
      type = types.str;
    };

    lidarrUrl = mkOption {
      default = "http://127.0.0.1:8686";
      description = "Base URL of the Lidarr instance to sync with.";
      example = "http://127.0.0.1:8686";
      type = types.nullOr types.str;
    };

    musicPath = mkOption {
      default = null;

      description = ''
        Final music library location (Lidarr's root folder). Must be writable
        by the service user.
      '';

      example = "/data/music";
      type = types.nullOr types.path;
    };

    package = mkPackageOption pkgs "lidarr-youtube-downloader" { };

    port = mkOption {
      default = 5005;
      description = "Port the web UI listens on.";
      type = types.port;
    };

    user = mkOption {
      default = "lidarr-youtube-downloader";
      description = "User the service runs as.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.lidarr-youtube-downloader = {
        after = [ "network-online.target" ];
        description = "Lidarr YouTube Downloader";

        environment = {
          FLASK_HOST = cfg.host;
          FLASK_PORT = toString cfg.port;
        }
        // optionalAttrs (cfg.lidarrUrl != null) { LIDARR_URL = cfg.lidarrUrl; }
        // optionalAttrs (cfg.downloadPath != null) { DOWNLOAD_PATH = toString cfg.downloadPath; }
        // optionalAttrs (cfg.musicPath != null) { LIDARR_PATH = toString cfg.musicPath; }
        // cfg.extraEnvironment;
        serviceConfig = {
          BindPaths = [ "/var/lib/lidarr-youtube-downloader:/config" ];
          EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = getExe cfg.package;
          Group = cfg.group;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";

          ReadWritePaths =
            optional (cfg.downloadPath != null) cfg.downloadPath
            ++ optional (cfg.musicPath != null) cfg.musicPath;

          Restart = "on-failure";
          # The app hardcodes /config: bind the state directory there.
          StateDirectory = "lidarr-youtube-downloader";
          StateDirectoryMode = "0750";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

      # The download directory must exist, group-writable.
      tmpfiles.rules = optional (
        cfg.downloadPath != null
      ) "d ${cfg.downloadPath} 2775 ${cfg.user} ${cfg.group} - -";
    };

    users = {
      groups = mkIf (cfg.group == "lidarr-youtube-downloader") {
        lidarr-youtube-downloader = { };
      };

      users = mkIf (cfg.user == "lidarr-youtube-downloader") {
        lidarr-youtube-downloader = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };
    };
  };
}
