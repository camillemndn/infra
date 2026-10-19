{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.webtrees;
  dataDir = "/var/lib/webtrees";
in
with lib;

{
  options.services.webtrees = {
    enable = mkEnableOption "Webtrees";

    hostName = mkOption {
      description = "FQDN for the Webtrees instance.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services = {
      mysql = {
        enable = true;
        ensureDatabases = [ "webtrees" ];

        ensureUsers = [
          {
            ensurePermissions = {
              "webtrees.*" = "ALL PRIVILEGES";
            };

            name = "webtrees";
          }
        ];

        package = mkDefault pkgs.mariadb;
      };

      nginx.virtualHosts.${cfg.hostName} = {
        locations = {
          "/".extraConfig = ''
            rewrite ^ /index.php last;
          '';

          "/index.php" = {
            extraConfig = ''
              fastcgi_pass unix:${config.services.phpfpm.pools.webtrees.socket};
            '';

            fastcgiParams = {
              HTTP_PROXY = "";
              SCRIPT_FILENAME = "$request_filename";
            };
          };

          "/public/".extraConfig = ''
            expires 365d;
            access_log off;
          '';

          "~ ^/(data|webtrees|modules|resources|vendor)/".extraConfig = ''
            deny all;
          '';
        };

        root = "${pkgs.webtrees}/share/php/webtrees";
      };

      phpfpm.pools.webtrees = {
        phpOptions = ''
          post_max_size = 5M
          upload_max_filesize = 5M
        '';

        phpPackage = pkgs.php84;

        settings = {
          "catch_workers_output" = true;
          "listen.owner" = config.services.nginx.user;
          "php_admin_flag[log_errors]" = true;
          "php_admin_value[error_log]" = "stderr";
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.max_requests" = 500;
          "pm.max_spare_servers" = 5;
          "pm.min_spare_servers" = 2;
          "pm.start_servers" = 2;
        };

        user = "webtrees";
      };
    };

    systemd = {
      services = {
        "phpfpm-webtrees".serviceConfig.BindPaths = [
          "/var/lib/webtrees/:${pkgs.webtrees}/share/php/webtrees/data/"
        ];

        webtrees-config = {
          before = [ "phpfpm-webtrees.service" ];

          script = ''
            if [ ! -f ${dataDir}/index.php ]; then
            cp -r ${pkgs.webtrees}/share/php/webtrees/data/* ${dataDir}
              chown -R webtrees ${dataDir}
              chmod -R ugo=rX ${dataDir}
              chmod -R ug+w ${dataDir}
            fi
          '';

          serviceConfig = {
            StateDirectory = "webtrees";
            Type = "oneshot";
            User = "webtrees";
          };

          wantedBy = [ "multi-user.target" ];
        };
      };
    };

    users = {
      groups.webtrees = { };

      users.webtrees = {
        group = "webtrees";
        isSystemUser = true;
      };
    };
  };
}
