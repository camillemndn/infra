{ config, lib, pkgs, ... }:

let
  cfg = config.services.koel;
  dataDir = "/var/lib/koel";

  envParams = {
    APP_NAME = "Koel";
    APP_ENV = "production";
    APP_DEBUG = "\"false\"";
    APP_URL = "\"https://${cfg.hostName}\"";
    DB_CONNECTION = "mysql";
    DB_HOST = "localhost";
    DB_PORT = "3306";
    DB_DATABASE = "koel";
    DB_USERNAME = "koel";
    IGNORE_DOT_FILES = "true";
    APP_MAX_SCAN_TIME = "3600";
    STREAMING_METHOD = "x-accel-redirect";
    OUTPUT_BIT_RATE = "1024";
    ALLOW_DOWNLOAD = "true";
    BACKUP_ON_DELETE = "true";
    BROADCAST_DRIVER = "log";
    CACHE_DRIVER = "file";
    FILESYSTEM_DISK = "local";
    QUEUE_CONNECTION = "sync";
    SESSION_DRIVER = "file";
    SESSION_LIFETIME = "120";
    LASTFM_API_KEY = "$LASTFM_API_KEY";
    LASTFM_API_SECRET = "$LASTFM_API_SECRET";
    SPOTIFY_CLIENT_ID = "$SPOTIFY_CLIENT_ID";
    SPOTIFY_CLIENT_SECRET = "$SPOTIFY_CLIENT_SECRET";
    YOUTUBE_API_KEY = "$YOUTUBE_API_KEY";
  } // cfg.extraConfig;

  envFile = with lib; concatStrings (mapAttrsToList (name: value: "${name}=${value}\n") envParams);
in
with lib;

{
  options.services.koel = {
    enable = mkEnableOption "Music player.";

    hostName = mkOption {
      type = types.str;
      description = lib.mdDoc "FQDN for the Koel instance.";
    };

    extraConfig = mkOption {
      type = types.attrsOf types.str;
      description = lib.mdDoc ''
        Environment variables for Laravel.
      '';
    };

    secretEnvFile = mkOption {
      type = types.str;
      description = lib.mdDoc "API keys and whatnot";
    };

    group = mkOption {
      type = types.str;
      default = "koel";
      example = "dialout";
      description = lib.mdDoc ''
        Default group that the "koel" user should be a part of.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.phpfpm.pools.koel = {
      user = "koel";
      group = cfg.group;
      settings = {
        "listen.owner" = config.services.nginx.user;
        "pm" = "dynamic";
        "pm.max_children" = 100;
        "pm.max_requests" = 500;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 5;
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
      };

      phpEnv = {
        PATH = with pkgs; makeBinPath [ php ffmpeg ];
        FFMPEG_PATH = "${pkgs.ffmpeg}/bin/ffmpeg";
      } // envParams;

      phpOptions = ''
        memory_limit = 2G
      '';
    };

    systemd.services."phpfpm-koel".serviceConfig = {
      EnvironmentFile = cfg.secretEnvFile;
      BindPaths = [
        "${dataDir}/storage:${pkgs.koel}/storage"
        "${dataDir}/database:${pkgs.koel}/database"
        "${dataDir}/public/img:${pkgs.koel}/public/img"
      ];
    };
    systemd.services.nginx.serviceConfig.BindPaths = [
      "${dataDir}/public/img:${pkgs.koel}/public/img"
    ];

    services.nginx = {
      enable = true;
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;

      virtualHosts.${cfg.hostName} = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          root            ${pkgs.koel}/public;
          index           index.php;

          gzip            on;
          gzip_types      text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript application/json;
          gzip_comp_level  9;

          location /media/ {
            internal;

            alias       $upstream_http_x_media_root;

            #access_log /var/log/nginx/koel.access.log;
            #error_log  /var/log/nginx/koel.error.log;
          }

          location / {
            try_files   $uri $uri/ /index.php?$args;
            allow 100.10.10.0/8;
            deny all;
          }  

          location ~ \.php$ {
            try_files $uri $uri/ /index.php?$args;

            fastcgi_param     PATH_INFO $fastcgi_path_info;
            fastcgi_param     PATH_TRANSLATED $document_root$fastcgi_path_info;
            fastcgi_param     SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_pass unix:${config.services.phpfpm.pools.koel.socket};
            fastcgi_index             index.php;
            fastcgi_split_path_info   ^(.+\.php)(/.+)$;
            fastcgi_intercept_errors  on;
          }
        '';
      };
    };

    services.mysql = {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureUsers = [{
        name = "koel";
        ensurePermissions = {
          "koel.*" = "ALL PRIVILEGES";
        };
      }];
      ensureDatabases = [ "koel" ];
    };

    users.users.koel = {
      isSystemUser = true;
      group = cfg.group;
      packages = [ pkgs.php ];
    };

    systemd.services."koel-config" = {
      wantedBy = [ "multi-user.target" ];
      requiredBy = [ "koel-init.service" ];
      serviceConfig = {
        StateDirectory = "koel";
        User = "koel";
        Group = cfg.group;
        Type = "oneshot";
      };
      script = ''
        cd ${dataDir}

        if [ ! -d storage ]; then
          shopt -s dotglob
          
          cp -r ${builtins.toFile "env-koel" envFile} .env
          echo "APP_KEY=base64:$(${pkgs.openssl}/bin/openssl rand -base64 32)" >> .env
          cp -r ${pkgs.koel}/storage .
          cp -r ${pkgs.koel}/database .
          mkdir -p public
          cp -r ${pkgs.koel}/public/img public
          
          chown -R koel:mediasrv .
          chmod -R ugo=rX .
          chmod -R ug+w .
        fi
      '';
    };

    systemd.services."koel-init" = {
      wantedBy = [ "multi-user.target" ];
      requiredBy = [ "phpfpm-koel.service" ];
      serviceConfig = {
        StateDirectory = "koel";
        User = "koel";
        Group = cfg.group;
        BindPaths = [
          "${dataDir}/storage:${pkgs.koel}/storage"
          "${dataDir}/database:${pkgs.koel}/database"
          "${dataDir}/public/img:${pkgs.koel}/public/img"
          "${dataDir}/.env:${pkgs.koel}/.env"
        ];
        Type = "oneshot";
        ProtectHome = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        NoNewPrivileges = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
        PrivateNetwork = true;
      };
      environment = envParams;
      script = ''
        cd ${dataDir}
        if [ ! -f storage/logs/laravel.log ]; then
          ${pkgs.php}/bin/php ${pkgs.koel}/artisan koel:init --no-interaction --no-assets
        fi
      '';
    };
  };
}
