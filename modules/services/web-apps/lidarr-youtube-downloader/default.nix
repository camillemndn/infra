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

    package = mkPackageOption pkgs "lidarr-youtube-downloader" { };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address the web UI binds to.";
    };

    port = mkOption {
      type = types.port;
      default = 5005;
      description = "Port the web UI listens on.";
    };

    lidarrUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "http://127.0.0.1:8686";
      description = "Base URL of the Lidarr instance to sync with.";
    };

    downloadPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/data/downloads";
      description = ''
        Directory downloads are written to. Must be writable by the service
        user (see {option}`services.lidarr-youtube-downloader.group`).
      '';
    };

    musicPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/data/music";
      description = ''
        Final music library location (Lidarr's root folder). Must be writable
        by the service user.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "lidarr-youtube-downloader";
      description = "User the service runs as.";
    };

    group = mkOption {
      type = types.str;
      default = "lidarr-youtube-downloader";
      description = ''
        Group the service runs as. Set this to a shared media group so the
        service can write to the download and music directories.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/lidarr-youtube-downloader.env";
      description = ''
        Path to an EnvironmentFile holding secrets such as `LIDARR_API_KEY`
        and `ACOUSTID_API_KEY`. Keeps them out of the world-readable Nix store.
        All other settings can also be configured from the web UI, which
        persists them to `/config/config.json` in the state directory.
      '';
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        SCHEDULER_ENABLED = "true";
        SCHEDULER_INTERVAL = "120";
      };
      description = "Extra environment variables passed to the service.";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "lidarr-youtube-downloader") {
      lidarr-youtube-downloader = {
        isSystemUser = true;
        inherit (cfg) group;
      };
    };

    users.groups = mkIf (cfg.group == "lidarr-youtube-downloader") {
      lidarr-youtube-downloader = { };
    };

    systemd.services.lidarr-youtube-downloader = {
      description = "Lidarr YouTube Downloader";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        FLASK_HOST = cfg.host;
        FLASK_PORT = toString cfg.port;
      }
      // optionalAttrs (cfg.lidarrUrl != null) { LIDARR_URL = cfg.lidarrUrl; }
      // optionalAttrs (cfg.downloadPath != null) { DOWNLOAD_PATH = toString cfg.downloadPath; }
      // optionalAttrs (cfg.musicPath != null) { LIDARR_PATH = toString cfg.musicPath; }
      // cfg.extraEnvironment;

      serviceConfig = {
        ExecStart = getExe cfg.package;
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";

        # The app hardcodes /config for its config.json and SQLite DB; map the
        # persistent state directory onto it instead of patching the source.
        StateDirectory = "lidarr-youtube-downloader";
        StateDirectoryMode = "0750";
        BindPaths = [ "/var/lib/lidarr-youtube-downloader:/config" ];

        EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;

        # Hardening.
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths =
          optional (cfg.downloadPath != null) cfg.downloadPath
          ++ optional (cfg.musicPath != null) cfg.musicPath;
      };
    };
  };
}
