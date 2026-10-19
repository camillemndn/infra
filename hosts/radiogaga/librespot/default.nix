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
  imports = [ ./module.nix ];
  networking.firewall.allowedTCPPorts = [ cfg.settings.zeroconf-port ];

  services = {
    librespot = {
      enable = true;

      settings = {
        name = "radiogaga";
        bitrate = 320;
        zeroconf-backend = "avahi";
        zeroconf-port = 35729;
      };

      package = pkgs.unstable.librespot.override (_: {
        withAvahi = true;
      });
    };

    avahi = {
      enable = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
