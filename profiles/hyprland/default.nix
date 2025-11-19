{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.hyprland.enable {
  environment = {
    systemPackages =
      with pkgs;
      [
        brightnessctl
        grim
        slurp
        swayidle
        swaylock
        wl-clipboard
      ]
      ++ (lib.optional config.services.tailscale.enable tailscale-systray);
  };
}
