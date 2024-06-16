{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.swayidle;
in
with lib;

{
  options.profiles.swayidle = {
    enable = mkEnableOption "Sway Idle";
  };

  config = mkIf cfg.enable {
    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
        }
        {
          event = "lock";
          command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
        }
      ];

      timeouts = [
        {
          timeout = 300;
          command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";
          resumeCommand = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
        }
        {
          timeout = 310;
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
      ];
    };

    systemd.user.services.swayidle.Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
  };
}
