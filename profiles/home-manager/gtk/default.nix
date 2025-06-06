{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.gtk;
in
with lib;

{
  options.gtk.hidpi.enable = mkEnableOption "GTK & QT settings";

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
      iconTheme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
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
      platformTheme.name = lib.mkForce "adwaita";
    };

    home.sessionVariables = {
      DISABLE_QT5_COMPAT = "0";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    };

    xdg.desktopEntries.xterm = {
      name = "";
      exec = "";
      noDisplay = true;
    };
  };
}
