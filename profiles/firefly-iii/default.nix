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
      settings.DB_CONNECTION = "pgsql";
    };

    firefly-iii-data-importer = {
      virtualHost = "import.finances.kms";
      enableNginx = true;
    };
  };
}
