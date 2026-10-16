{
  config,
  pkgs,
  ...
}:

{
  services = {
    immich = {
      enable = true;
      package = pkgs.unstable.immich;
      database.enable = true;
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
