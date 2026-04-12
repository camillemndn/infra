{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.immich.enable {
  services = {
    immich = {
      database = {
        enable = true;
        enableVectors = false;
      };
      host = "127.0.0.1";
    };

    nginx.virtualHosts."gallery.kms" = {
      inherit (config.services.immich) port;
      websockets = true;
      extraConfig = ''
        client_max_body_size 0;
      '';
    };
  };
}
