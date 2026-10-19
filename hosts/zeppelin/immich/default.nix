{
  config,
  pkgs,
  ...
}:

{
  services = {
    immich = {
      enable = true;
      host = "127.0.0.1";
      package = pkgs.unstable.immich;
    };

    nginx.virtualHosts."gallery.kms" = {
      inherit (config.services.immich) port;

      extraConfig = ''
        client_max_body_size 0;
      '';

      websockets = true;
    };
  };
}
