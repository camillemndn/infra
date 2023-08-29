{ config, lib, ... }:

let
  cfg = config.profiles.gdm;
in
with lib;

{
  options.profiles.gdm = {
    enable = mkEnableOption "GDM";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager = {
        gdm = {
          wayland = true;
          enable = true;

          extraConfig = ''
            [org/gnome/desktop/interface]
            cursor-size=24
            text-scaling-factor=1.5
            scaling-factor=2
            show-battery-percentage=true
          '';
        };

        setupCommands = ''
          xrandr --setprovideroutputsource modesetting NVIDIA-0
          xrandr --auto
        '';
      };

      layout = "fr";
      xkbVariant = "";
    };
  };
}
