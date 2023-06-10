{ config, lib, pkgs, ... }:

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
      description = lib.mdDoc "FQDN for the Webtrees instance.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedGzipSettings = true;
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
    systemd.services."phpfpm-webtrees".serviceConfig.BindPaths = [ "/var/lib/webtrees/:${pkgs.webtrees}/data/" ];

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.hostName} = {
        forceSSL = true;
        enableACME = true;
        root = "${pkgs.webtrees}";
        locations."/public/".extraConfig = ''
          expires 365d;
          access_log off;
        '';
        locations."/".extraConfig = ''
          rewrite ^ /index.php last;
        '';
        locations."~ ^/(data|webtrees|modules|resources|vendor)/".extraConfig = ''
          deny all;
        '';
        locations."/index.php".extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.webtrees.socket};
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
          name = "webtrees";
          ensurePermissions = {
            "webtrees.*" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "webtrees" ];
    };

    users.users.webtrees = {
      isSystemUser = true;
      group = "webtrees";
    };
    users.groups.webtrees = { };

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
          cp -r ${pkgs.webtrees}/data/* ${dataDir}
          chown -R webtrees ${dataDir}
          chmod -R ugo=rX ${dataDir}
          chmod -R ug+w ${dataDir}
        fi
      '';
    };
  };
}
