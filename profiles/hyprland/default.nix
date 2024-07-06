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
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
          "Ubuntu"
        ];
      })
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
