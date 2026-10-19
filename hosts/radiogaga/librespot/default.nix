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
    avahi = {
      enable = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };

    librespot = {
      enable = true;

      package = pkgs.unstable.librespot.override (_: {
        withAvahi = true;
      });

      settings = {
        bitrate = 320;
        name = "radiogaga";
        zeroconf-backend = "avahi";
        zeroconf-port = 35729;
      };
    };
  };
}
