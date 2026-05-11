{
  config,
  lib,
  pkgs,
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
      virtualHost = "import.finances.kms";
      enableNginx = true;
    };
  };

  age.secrets.firefly-iii-app-key.file = ./app-key.age;
}
