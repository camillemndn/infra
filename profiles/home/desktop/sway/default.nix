{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.sway;
in
with lib;

{
  options.profiles.sway = {
    enable = mkEnableOption "activate sway WM";
  };

  config = mkIf cfg.enable {
    profiles.waybar.enable = true;
    profiles.rofi.enable = true;
    profiles.kitty.enable = true;

    gtk = {
      enable = true;

      theme = {
        name = "Catppuccin-Mocha-Standard-Mauve-Dark";
        package = pkgs.catppuccin-gtk;
      };

      iconTheme = {
        name = "Yaru-dark";
        package = pkgs.yaru-theme;
      };

      #font = {
      #  name = "Inter";
      #  size = 13;
      #};

      gtk3.extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-decoration-layout = "menu:";
      };

      gtk2.extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita-dark";
      };
    };

    #home.pointerCursor = {
    #  name = "Adwaita-dark";
    #  package = pkgs.gnome.adwaita-icon-theme;
    #  size = 94;
    #  gtk.enable = true;
    #};

    home.sessionVariables = {
      # Theming Related Variables
      XCURSOR_SIZE = "32";
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        bars = [{ statusCommand = "waybar"; }];
        gaps.inner = 8;
        input."*" = { xkb_layout = "fr"; natural_scroll = "enabled"; tap = "enabled"; };
        menu = "rofi -modi drun -show";
        modifier = "Mod4";

        #startup = [
        #  { command = "waybar"; }
        #];

        terminal = "kitty";
        window.titlebar = false;
      };
    };
  };
}
