{
  config,
  lib,
  ...
}:

lib.mkIf config.services.firefly-iii.enable {
  services = {
    firefly-iii = {
      virtualHost = "finances.kms";
      enableNginx = true;
      settings = {
        APP_KEY_FILE = config.age.secrets.firefly-iii-app-key.path;
        DB_CONNECTION = "pgsql";
      };
    };

    firefly-iii-data-importer = {
      enable = true;
      virtualHost = "import.finances.kms";
      enableNginx = true;
    };

    postgresql = {
      ensureUsers = [
        {
          name = "firefly-iii";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "firefly-iii" ];
    };

    nginx.virtualHosts."finances.kms".locations."~ \\.php$".extraConfig = lib.mkAfter ''
      fastcgi_read_timeout 3600;
    '';

    phpfpm.pools = {
      firefly-iii.phpOptions = ''
        log_errors = on
        max_execution_time = 3600
        memory_limit = 4G
      '';

      firefly-iii-data-importer.phpOptions = ''
        log_errors = on
        max_execution_time = 3600
      '';
    };
  };

  age.secrets.firefly-iii-app-key = {
    owner = config.services.firefly-iii.user;
    file = ./app-key.age;
  };
}
