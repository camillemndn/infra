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

    fonts = {
      fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Ubuntu" ]; })
      ];
      fontconfig.antialias = true;
    };

    environment = {
      systemPackages = with pkgs; [
        waybar
        hyprpaper
      ];
    };

    programs.hyprland.enable = true;
  };
}
