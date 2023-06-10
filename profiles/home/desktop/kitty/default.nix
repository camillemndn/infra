{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.kitty;
in
with lib;

{
  options.profiles.kitty = {
    enable = mkEnableOption "activate kitty program";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      font = {
        name = "FiraCode Nerd Font";
        package = with pkgs; (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; });
        size = 15;
      };

      theme = "Catppuccin-Mocha";

      settings = {
        #linux_display_server = "x11";
        #hide_window_decorations = "yes";
        wayland_titlebar_color = "background";
        background_opacity = "0.8";
      };
    };
  };
}
