{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.kitty;
in
with lib;

{
  options.profiles.kitty = {
    enable = mkEnableOption "Kitty terminal";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      font = {
        name = "FiraCode Nerd Font Mono Reg";
        package = with pkgs; (nerdfonts.override { fonts = [ "FiraCode" ]; });
        size = 15;
      };

      theme = "Catppuccin-Mocha";

      settings = {
        wayland_titlebar_color = "background";
        background_opacity = "0.8";
      };
    };
  };
}

