{ config, lib, ... }:

let
  cfg = config.profiles.gdm;
in
with lib;

{
  options.profiles.gdm = {
    enable = mkEnableOption "GDM";
    hidpi.enable = mkEnableOption "High DPI";
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
            text-scaling-factor=${if cfg.hidpi.enable then "1.5" else "1.0"}
            scaling-factor=${if cfg.hidpi.enable then "2" else "1"}
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
