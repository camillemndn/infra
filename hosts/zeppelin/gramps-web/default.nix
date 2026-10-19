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
    GRAMPSWEB_BASE_URL = "https://${cfg.hostName}";
    GRAMPSWEB_CELERY_CONFIG__broker_url = "redis+socket://${redis.unixSocket}";
    GRAMPSWEB_CELERY_CONFIG__result_backend = "redis+socket://${redis.unixSocket}";
    GRAMPSWEB_DISABLE_TELEMETRY = "True";
    GRAMPSWEB_EXPORT_DIR = "${cacheDir}/export";
    GRAMPSWEB_MEDIA_BASE_DIR = "${stateDir}/media";
    GRAMPSWEB_PERSISTENT_CACHE_CONFIG__CACHE_DIR = "${stateDir}/persistent_cache";
    GRAMPSWEB_RATELIMIT_STORAGE_URI = "redis+unix://${redis.unixSocket}?db=1";
    GRAMPSWEB_REGISTRATION_DISABLED = "True";
    GRAMPSWEB_REPORT_DIR = "${cacheDir}/reports";
    GRAMPSWEB_REQUEST_CACHE_CONFIG__CACHE_DIR = "${cacheDir}/request_cache";
    GRAMPSWEB_SEARCH_INDEX_DB_URI = "sqlite:///${stateDir}/search_index.db";
    GRAMPSWEB_STATIC_PATH = "${pkgs.gramps-web}";
    GRAMPSWEB_THUMBNAIL_CACHE_CONFIG__CACHE_DIR = "${cacheDir}/thumbnail_cache";
    GRAMPSWEB_TREE = cfg.tree;
    GRAMPSWEB_USER_DB_URI = "sqlite:///${stateDir}/users.sqlite";
    GRAMPS_DATABASE_PATH = "${stateDir}/grampsdb";
  };

  # Same dynamic user for both units: shared data and secret key.
  serviceConfig = {
    CacheDirectory = "gramps-web";
    DynamicUser = true;
    Restart = "on-failure";
    StateDirectory = "gramps-web";
    SupplementaryGroups = [ redis.group ];
    User = "gramps-web";
    WorkingDirectory = stateDir;
  };
in
with lib;

{
  options.services.gramps-web = {
    enable = mkEnableOption "Gramps Web";

    hostName = mkOption {
      description = "FQDN for the Gramps Web instance.";
      type = types.str;
    };

    port = mkOption {
      default = 5056;
      description = "Local port the API server listens on.";
      type = types.port;
    };

    tree = mkOption {
      default = "Family";
      description = "Name of the Gramps family tree, created empty on first start.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services = {
      nginx.virtualHosts.${cfg.hostName} = {
        inherit (cfg) port;

        locations."/".extraConfig = ''
          client_max_body_size 500M;
        '';
      };

      redis.servers.gramps-web = {
        enable = true;
        port = 0;
      };
    };

    systemd = {
      services = {
        gramps-web = {
          inherit environment serviceConfig;

          after = [
            "network.target"
            "redis-gramps-web.service"
          ];

          description = "Gramps Web";

          # The Flask secret key is generated once and kept with the data.
          preStart = ''
            if [ ! -s ${stateDir}/secret ]; then
              (umask 077; head -c 32 /dev/urandom | base64 > ${stateDir}/secret)
            fi
            mkdir -p ${stateDir}/media ${stateDir}/grampsdb
            (cd ${migrations} && GRAMPSWEB_SECRET_KEY=$(cat ${stateDir}/secret) ${gramps-webapi} user migrate)
          '';

          requires = [ "redis-gramps-web.service" ];

          script = ''
            export GRAMPSWEB_SECRET_KEY=$(cat ${stateDir}/secret)
            exec ${gramps-webapi} run --use-wsgi --host 127.0.0.1 --port ${toString cfg.port}
          '';

          wantedBy = [ "multi-user.target" ];
        };

        gramps-web-celery = {
          inherit environment serviceConfig;

          # Creates the secret key and migrates the user database.
          after = [
            "gramps-web.service"
            "redis-gramps-web.service"
          ];

          description = "Gramps Web background tasks";
          requires = [ "redis-gramps-web.service" ];

          script = ''
            export GRAMPSWEB_SECRET_KEY=$(cat ${stateDir}/secret)
            exec ${python}/bin/celery -A gramps_webapi.celery worker --loglevel=INFO --concurrency=2
          '';

          wantedBy = [ "multi-user.target" ];
        };
      };
    };
  };
}
