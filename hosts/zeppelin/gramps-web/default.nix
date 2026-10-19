{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gramps-web;
  stateDir = "/var/lib/gramps-web";
  cacheDir = "/var/cache/gramps-web";
  redis = config.services.redis.servers.gramps-web;
  python = pkgs.python3.withPackages (ps: [ (ps.toPythonModule pkgs.gramps-webapi) ]);
  gramps-webapi = "${python}/bin/python -m gramps_webapi";

  # Alembic needs alembic.ini and the migrations in its working directory; the wheel ships neither.
  migrations = pkgs.runCommand "gramps-webapi-migrations" { } ''
    mkdir $out
    cp -r ${pkgs.gramps-webapi.src}/{alembic.ini,alembic_users} $out
  '';

  environment = {
    GI_TYPELIB_PATH = lib.makeSearchPath "lib/girepository-1.0" (
      map lib.getLib (
        with pkgs;
        [
          atk
          gdk-pixbuf
          gexiv2
          glib
          gobject-introspection
          gtk3
          harfbuzz
          pango
        ]
      )
    );

    GRAMPSHOME = stateDir;
    GRAMPS_DATABASE_PATH = "${stateDir}/grampsdb";
    GRAMPSWEB_TREE = cfg.tree;
    GRAMPSWEB_BASE_URL = "https://${cfg.hostName}";
    GRAMPSWEB_STATIC_PATH = "${pkgs.gramps-web}";
    GRAMPSWEB_REGISTRATION_DISABLED = "True";
    GRAMPSWEB_DISABLE_TELEMETRY = "True";
    GRAMPSWEB_USER_DB_URI = "sqlite:///${stateDir}/users.sqlite";
    GRAMPSWEB_SEARCH_INDEX_DB_URI = "sqlite:///${stateDir}/search_index.db";
    GRAMPSWEB_MEDIA_BASE_DIR = "${stateDir}/media";
    GRAMPSWEB_THUMBNAIL_CACHE_CONFIG__CACHE_DIR = "${cacheDir}/thumbnail_cache";
    GRAMPSWEB_REQUEST_CACHE_CONFIG__CACHE_DIR = "${cacheDir}/request_cache";
    GRAMPSWEB_PERSISTENT_CACHE_CONFIG__CACHE_DIR = "${stateDir}/persistent_cache";
    GRAMPSWEB_REPORT_DIR = "${cacheDir}/reports";
    GRAMPSWEB_EXPORT_DIR = "${cacheDir}/export";
    GRAMPSWEB_CELERY_CONFIG__broker_url = "redis+socket://${redis.unixSocket}";
    GRAMPSWEB_CELERY_CONFIG__result_backend = "redis+socket://${redis.unixSocket}";
    GRAMPSWEB_RATELIMIT_STORAGE_URI = "redis+unix://${redis.unixSocket}?db=1";
  };

  # Same dynamic user for both units: shared data and secret key.
  serviceConfig = {
    DynamicUser = true;
    User = "gramps-web";
    SupplementaryGroups = [ redis.group ];
    StateDirectory = "gramps-web";
    CacheDirectory = "gramps-web";
    WorkingDirectory = stateDir;
    Restart = "on-failure";
  };
in
with lib;

{
  options.services.gramps-web = {
    enable = mkEnableOption "Gramps Web";

    hostName = mkOption {
      type = types.str;
      description = "FQDN for the Gramps Web instance.";
    };

    port = mkOption {
      type = types.port;
      default = 5056;
      description = "Local port the API server listens on.";
    };

    tree = mkOption {
      type = types.str;
      default = "Family";
      description = "Name of the Gramps family tree, created empty on first start.";
    };
  };

  config = mkIf cfg.enable {
    services = {
      redis.servers.gramps-web = {
        enable = true;
        port = 0;
      };

      nginx.virtualHosts.${cfg.hostName} = {
        inherit (cfg) port;

        locations."/".extraConfig = ''
          client_max_body_size 500M;
        '';
      };
    };

    systemd = {
      services = {
        gramps-web = {
          description = "Gramps Web";
          wantedBy = [ "multi-user.target" ];
          requires = [ "redis-gramps-web.service" ];

          after = [
            "network.target"
            "redis-gramps-web.service"
          ];

          inherit environment serviceConfig;

          # The Flask secret key is generated once and kept with the data.
          preStart = ''
            if [ ! -s ${stateDir}/secret ]; then
              (umask 077; head -c 32 /dev/urandom | base64 > ${stateDir}/secret)
            fi
            mkdir -p ${stateDir}/media ${stateDir}/grampsdb
            (cd ${migrations} && GRAMPSWEB_SECRET_KEY=$(cat ${stateDir}/secret) ${gramps-webapi} user migrate)
          '';

          script = ''
            export GRAMPSWEB_SECRET_KEY=$(cat ${stateDir}/secret)
            exec ${gramps-webapi} run --use-wsgi --host 127.0.0.1 --port ${toString cfg.port}
          '';
        };

        gramps-web-celery = {
          description = "Gramps Web background tasks";
          wantedBy = [ "multi-user.target" ];
          requires = [ "redis-gramps-web.service" ];

          # Creates the secret key and migrates the user database.
          after = [
            "gramps-web.service"
            "redis-gramps-web.service"
          ];

          inherit environment serviceConfig;

          script = ''
            export GRAMPSWEB_SECRET_KEY=$(cat ${stateDir}/secret)
            exec ${python}/bin/celery -A gramps_webapi.celery worker --loglevel=INFO --concurrency=2
          '';
        };
      };
    };
  };
}
