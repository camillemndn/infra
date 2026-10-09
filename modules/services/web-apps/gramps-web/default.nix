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

  python = pkgs.python3.withPackages (ps: [ (ps.toPythonModule pkgs.gramps-webapi) ]);
  gramps-webapi = "${python}/bin/python -m gramps_webapi";

  # Alembic reads alembic.ini from the working directory; the wheel ships neither it nor the
  # migration scripts.
  migrations = pkgs.runCommand "gramps-webapi-migrations" { } ''
    mkdir $out
    cp -r ${pkgs.gramps-webapi.src}/{alembic.ini,alembic_users} $out
  '';
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
    systemd.services.gramps-web = {
      description = "Gramps Web";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        GI_TYPELIB_PATH = makeSearchPath "lib/girepository-1.0" (
          map getLib (
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
        GRAMPSWEB_USER_DB_URI = "sqlite:///${stateDir}/users.sqlite";
        GRAMPSWEB_SEARCH_INDEX_DB_URI = "sqlite:///${stateDir}/search_index.db";
        GRAMPSWEB_MEDIA_BASE_DIR = "${stateDir}/media";
        GRAMPSWEB_THUMBNAIL_CACHE_CONFIG__CACHE_DIR = "${cacheDir}/thumbnail_cache";
        GRAMPSWEB_REQUEST_CACHE_CONFIG__CACHE_DIR = "${cacheDir}/request_cache";
        GRAMPSWEB_PERSISTENT_CACHE_CONFIG__CACHE_DIR = "${stateDir}/persistent_cache";
        GRAMPSWEB_REPORT_DIR = "${cacheDir}/reports";
        GRAMPSWEB_EXPORT_DIR = "${cacheDir}/export";
      };

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

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "gramps-web";
        CacheDirectory = "gramps-web";
        WorkingDirectory = stateDir;
        Restart = "on-failure";
      };
    };

    services.nginx.virtualHosts.${cfg.hostName} = {
      inherit (cfg) port;
      # Without a Celery worker, imports run inside the request.
      locations."/".extraConfig = ''
        client_max_body_size 500M;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
      '';
    };
  };
}
