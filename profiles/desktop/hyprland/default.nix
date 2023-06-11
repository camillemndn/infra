{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.hyprland;
in
with lib;

{
  options.profiles.hyprland = {
    enable = mkEnableOption "Hyprland";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      layout = "fr";
      xkbVariant = "";
    };

    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };

    fonts = {
      fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Ubuntu" ]; })
      ];
      fontconfig.antialias = true;
    };

    environment = {
      systemPackages = with pkgs; [
        wofi
        waybar
        hyprpaper
      ];
      variables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";
    };

    programs.hyprland.enable = true;
  };
}
