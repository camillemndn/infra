{ config, lib, pkgs, ... }:

let
  "organizr" = "organizr";
  cfg = config.services.organizr;
in
with lib;

{
  options.services.organizr = {
    enable = mkEnableOption "Organizr";

    hostName = mkOption {
      type = types.str;
      description = lib.mdDoc "FQDN for the Organizr instance.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedGzipSettings = true;
    services.phpfpm.pools.organizr = {
      user = "organizr";
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
      phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
    };
    systemd.services."phpfpm-organizr".serviceConfig.BindPaths = [ "/var/lib/organizr/:${pkgs.organizr}/data/" ];
    systemd.services."nginx".serviceConfig.BindPaths = [ "/var/lib/organizr/:${pkgs.organizr}/data/" ];
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.hostName} = {
        enableACME = true;
        forceSSL = true;
        root = "${pkgs.organizr}";
        locations."~ (/|\.php)$".extraConfig = ''
          fastcgi_index index.php;
          fastcgi_pass unix:${config.services.phpfpm.pools.organizr.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
          fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;  
          fastcgi_buffers 32 32k;
          fastcgi_buffer_size 32k;
        '';
        locations."/api/v2".extraConfig = ''
          try_files $uri /api/v2/index.php$is_args$args;
        '';
      };
    };

    users.users.organizr = {
      isSystemUser = true;
      group = "organizr";
    };
    users.groups.organizr = { };
  };
}
