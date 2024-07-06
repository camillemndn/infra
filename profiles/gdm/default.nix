{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.xserver.displayManager.gdm;
in

{
  options.services.xserver.displayManager.gdm = {
    hidpi.enable = lib.mkEnableOption "High DPI";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager = {
        gdm = {
          wayland = true;

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

      xkb = {
        layout = "fr";
        variant = "";
      };
    };

    environment.systemPackages = [
      pkgs.libheif
      pkgs.libheif.out
    ];
    environment.pathsToLink = [ "share/thumbnailers" ];
  };
}
