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

  fonts = {
    packages = with pkgs.nerd-fonts; [
      fira-code
      jetbrains-mono
      ubuntu
    ];
    fontconfig.antialias = true;
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
