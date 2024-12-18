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
      type = types.str;
      description = "FQDN for the Webtrees instance.";
    };
  };

  config = mkIf cfg.enable {
    services.phpfpm.pools.webtrees = {
      user = "webtrees";
      settings = {
        "listen.owner" = config.services.nginx.user;
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 5;
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
      };
      phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
      phpOptions = ''
        post_max_size = 5M
        upload_max_filesize = 5M
      '';
    };

    services.nginx.virtualHosts.${cfg.hostName} = {
      root = "${pkgs.webtrees}/share";
      locations = {
        "/public/".extraConfig = ''
          expires 365d;
          access_log off;
        '';
        "/".extraConfig = ''
          rewrite ^ /index.php last;
        '';
        "~ ^/(data|webtrees|modules|resources|vendor)/".extraConfig = ''
          deny all;
        '';
        "/index.php" = {
          fastcgiParams = {
            HTTP_PROXY = "";
            SCRIPT_FILENAME = "$request_filename";
          };
          extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.webtrees.socket};
          '';
        };
      };
    };

    services.mysql = {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureUsers = [
        {
          name = "webtrees";
          ensurePermissions = {
            "webtrees.*" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "webtrees" ];
    };

    systemd.services."phpfpm-webtrees".serviceConfig.BindPaths = [
      "/var/lib/webtrees/:${pkgs.webtrees}/share/data/"
    ];

    systemd.services.webtrees-config = {
      wantedBy = [ "multi-user.target" ];
      before = [ "phpfpm-webtrees.service" ];
      serviceConfig = {
        StateDirectory = "webtrees";
        User = "webtrees";
        Type = "oneshot";
      };
      script = ''
        if [ ! -f ${dataDir}/index.php ]; then
          cp -r ${pkgs.webtrees}/share/data/* ${dataDir}
          chown -R webtrees ${dataDir}
          chmod -R ugo=rX ${dataDir}
          chmod -R ug+w ${dataDir}
        fi
      '';
    };

    users.users.webtrees = {
      isSystemUser = true;
      group = "webtrees";
    };

    users.groups.webtrees = { };
  };
}
