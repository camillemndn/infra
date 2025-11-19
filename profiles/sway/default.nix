{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.sway.enable {
  programs.sway.extraPackages =
    with pkgs;
    [
      brightnessctl
      grim
      slurp
      swayidle
      swaylock
      wl-clipboard
    ]
    ++ (lib.optional config.services.tailscale.enable pkgs.tailscale-systray);
}
