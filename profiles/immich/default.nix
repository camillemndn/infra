{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.immich.enable {
  services = {
    immich = {
      database.enable = true;
    };

    nginx.virtualHosts."gallery.kms" = {
      inherit (config.services.immich) port;
      websockets = true;
    };
  };
}
