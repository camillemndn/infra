{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.sway;
in
with lib;

{
  options.profiles.sway = {
    enable = mkEnableOption "Sway";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      layout = "fr";
      xkbVariant = "";
    };

    programs.xwayland.enable = true;
    programs.sway = { enable = true; wrapperFeatures.gtk = true; };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-gtk ];
    };

    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };

    fonts = {
      fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
      ];
      fontconfig.antialias = true;
    };

    environment = {
      variables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";
      variables.XCURSOR_SIZE = "96";
      variables.XCURSOR_THEME = "Adwaita";
      variables.GDK_BACKEND = "wayland";
    };
  };
}
