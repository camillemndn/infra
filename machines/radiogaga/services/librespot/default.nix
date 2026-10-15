{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.librespot;
in

{
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.settings.zeroconf-port ];

    services = {
      avahi = {
        enable = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      librespot = {
        package = pkgs.unstable.librespot.override (_: {
          withAvahi = true;
        });

        settings = {
          bitrate = 320;
          zeroconf-backend = "avahi";
          zeroconf-port = 35729;
        };
      };
    };
  };
}
