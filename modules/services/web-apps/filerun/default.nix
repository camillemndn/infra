{ config, pkgs, lib, ... }:

with lib;
let
  app = "filerun";
  domain = "cloud.kms";
  dataDir = "/var/lib/${app}";
  cfg = config.services.${app};
in
{
  options.services.${app} = {
    enable = mkEnableOption "Enable ${app} service";
    dbname = mkOption {
      type = types.nullOr types.str;
      default = "${app}";
      description = "Database name.";
    };
    dbuser = mkOption {
      type = types.nullOr types.str;
      default = "${app}";
      description = "Database user.";
    };
    dbpassFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The full path to a file that contains the database password.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.libreoffice-fresh ];
    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedGzipSettings = true;
    services.phpfpm.pools.${app} = {
      user = app;
      phpPackage = pkgs.php74;
      phpOptions = ''
        zend_extension = ${pkgs.${app}}/ioncube/ioncube_loader_lin_7.4.so
        extension = ${pkgs.php74Extensions.imagick}/lib/php/extensions/imagick.so
        
        expose_php              = Off
        error_reporting         = E_ALL & ~E_NOTICE
        display_errors          = Off
        display_startup_errors  = Off
        log_errors              = Off
        ignore_repeated_errors  = Off
        allow_url_fopen         = On
        allow_url_include       = Off
        variables_order         = "GPCS"
        allow_webdav_methods    = On
        memory_limit            = 128M
        max_execution_time      = 300
        output_buffering        = Off
        output_handler          = ""
        zlib.output_compression = Off
        zlib.output_handler     = ""
        safe_mode               = Off
        register_globals        = Off
        magic_quotes_gpc        = Off
        date.timezone           = "Europe/Paris"
        file_uploads            = On
        upload_max_filesize     = 128M
        post_max_size           = 128M
        
        enable_dl               = Off
        disable_functions       = ""
        disable_classes         = ""
        
        session.save_handler     = files
        session.use_cookies      = 1
        session.use_only_cookies = 1
        session.auto_start       = 0
        session.cookie_lifetime  = 0
        session.cookie_httponly  = 1
        session.cookie_secure    = 1
        
        opcache.memory_consumption=128
        opcache.interned_strings_buffer=8
        opcache.max_accelerated_files=4000
        opcache.revalidate_freq=60
        opcache.fast_shutdown=1
        opcache.enable_cli=1
      '';
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
      phpEnv."PATH" = with pkgs; lib.makeBinPath [ php74 ghostscript vips ffmpeg pngquant libreoffice-fresh ];
      phpEnv."HOME" = "/tmp";
    };
    systemd.services."phpfpm-${app}".serviceConfig.BindPaths = [ "/var/lib/${app}:${pkgs.${app}}/system/data" ];
    services.nginx = {
      enable = true;
      virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        root = "${pkgs.${app}}";
        extraConfig = ''
          client_max_body_size 16G;
        '';
        locations."~* \.(jpg|jpeg|gif|png|webp|svg|woff|woff2|ttf|css|js|ico|xml)$".extraConfig = ''
          expires 365d;
          access_log off;
          log_not_found off;
        '';
        locations."/".extraConfig = ''
          index index.php;
          try_files $uri $uri/ /index.php;
        '';
        locations."~ /\.ht".extraConfig = ''
          access_log off;
          log_not_found off;
          deny all;
        '';
        locations."~ [^/]\.php(/|$)".extraConfig = ''
          fastcgi_split_path_info ^(.+?\.php)(/.*)$;
          if (!-f $document_root$fastcgi_script_name) {
            return 404;
          }
          fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_param PATH_INFO $fastcgi_path_info;
        '';
      };
    };

    services.mysql = {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureUsers = [
        {
          name = cfg.dbuser;
          ensurePermissions = {
            "${cfg.dbname}.*" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ cfg.dbname ];
    };

    users.users.${app} = {
      isNormalUser = true;
      createHome = true;
      home = dataDir;
      group = app;
    };
    users.groups.${app} = { };

    systemd.services."${app}-config" = {
      wantedBy = [ "multi-user.target" ];
      before = [ "phpfpm-${app}.service" ];
      serviceConfig = {
        StateDirectory = "${app}";
        User = "${app}";
      };
      script = ''
        cd ${dataDir}

        if [ ! -f ${dataDir}/index.html ]; then
          cp -r ${pkgs.${app}}/system/data/* .
          chown -R ${app}:${app} .
          chmod -R ugo=rX .
          chmod -R ug+w .
        fi
      '';
    };
  };
}
