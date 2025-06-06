{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.hyprland.enable {
  services.xserver = {
    enable = true;
    xkb = {
      layout = "fr";
      variant = "";
    };
  };

  environment = {
    systemPackages =
      with pkgs;
      [
        waybar
        hyprpaper
      ]
      ++ (lib.optional config.services.tailscale.enable tailscale-systray);
  };
}
