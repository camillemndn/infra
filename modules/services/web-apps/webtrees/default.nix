{ config, lib, pkgs, ... }:

let
  app = "webtrees";
  domain = "family.kms";
  dataDir = "/var/lib/${app}";
  cfg = config.services.webtrees;
in
with lib;

{
  options.services.webtrees = {
    enable = mkEnableOption "Webtrees";
  };

  config = mkIf cfg.enable {
    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedGzipSettings = true;
    services.phpfpm.pools.${app} = {
      user = app;
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
    systemd.services."phpfpm-${app}".serviceConfig.BindPaths = [ "/var/lib/${app}/:${pkgs.${app}}/data/" ];

    services.nginx = {
      enable = true;
      virtualHosts.${app} = {
        root = "${pkgs.${app}}";
        listen = [{
          addr = "localhost";
          port = 3228;
        }];
        locations."/public/".extraConfig = ''
          expires 365d;
          access_log off;
        '';
        locations."/".extraConfig = ''
          rewrite ^ /index.php last;
        '';
        locations."~ ^/(data|app|modules|resources|vendor)/".extraConfig = ''
          deny all;
        '';
        locations."/index.php".extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
          fastcgi_param HTTP_PROXY "";
          fastcgi_param SCRIPT_FILENAME $request_filename;
        '';
      };
    };

    services.mysql = {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureUsers = [
        {
          name = app;
          ensurePermissions = {
            "${app}.*" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "${app}" ];
    };

    users.users.${app} = {
      isSystemUser = true;
      group = app;
    };
    users.groups.${app} = { };

    systemd.services."${app}-config" = {
      wantedBy = [ "multi-user.target" ];
      before = [ "phpfpm-${app}.service" ];
      serviceConfig = {
        StateDirectory = "${app}";
        User = "${app}";
        Type = "oneshot";
      };
      script = ''
        if [ ! -f ${dataDir}/index.php ]; then
          cp -r ${pkgs.${app}}/data/* ${dataDir}
          chown -R ${app} ${dataDir}
          chmod -R ugo=rX ${dataDir}
          chmod -R ug+w ${dataDir}
        fi
      '';
    };
  };
}
