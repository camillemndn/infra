{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.gtk-qt;
in
with lib;

{
  options.profiles.gtk-qt = {
    enable = mkEnableOption "GTK & QT settings";
    hidpi.enable = mkEnableOption "GTK & QT settings";
  };

  config = mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        text-scaling-factor = mkIf cfg.hidpi.enable 1.5;
        scaling-factor = mkIf cfg.hidpi.enable 2;
        show-battery-percentage = true;
      };
      "org/gnome/desktop/wm/preferences".button-layout = ":close";
    };

    gtk = {
      enable = true;

      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };

      iconTheme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
      };

      font = {
        name = "Cantarell";
        size = 11;
      };

      gtk3.extraConfig = {
        gtk-xft-antialias = 1;
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
      platformTheme.name = "adwaita";
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita-dark";
      };
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
    };

    home.sessionVariables = {
      #  # Theming Related Variables
      #  XCURSOR_SIZE = "96";
      #  _JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";

      #  # XDG Specifications
      #  XDG_CURRENT_DESKTOP = "Hyprland";
      #  XDG_SESSION_TYPE = "wayland";
      #  XDG_SESSION_DESKTOP = "Hyprland";

      #  # QT Variables
      DISABLE_QT5_COMPAT = "0";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      #  QT_QPA_PLATFORM = "wayland";
      #  QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
      #  QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
      #  QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      #  # Toolkit Backend Variables
      #  SDL_VIDEODRIVER = "wayland";
      #  _JAVA_AWT_WM_NONREPARENTING = "1";
      #  CLUTTER_BACKEND = "wayland";
      #  GDK_BACKEND = "wayland";
      #  MOZ_ENABLE_WAYLAND = "1";
    };

    xdg.desktopEntries.xterm = { name = ""; exec = ""; noDisplay = true; };
  };
}

