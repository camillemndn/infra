{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.gnome;
in
with lib;

{
  options.profiles.gnome = {
    enable = mkEnableOption "Gnome";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      layout = "fr";
      xkbVariant = "";
    };

    programs.xwayland.enable = true;

    #qt = {
    #  enable = true;
    #  style = "adwaita-dark";
    #  platformTheme = "gnome";
    #};

    fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Ubuntu" ]; })
      ];
      fontconfig.antialias = true;
    };

    environment = {
      gnome.excludePackages = with pkgs; with gnome; [ geary epiphany gnome-calendar gnome-console ];

      systemPackages = with pkgs; with gnome; with gnomeExtensions; [
        dconf-editor
        tailscale-status
        screen-rotate
        nextcloud-folder
        blur-my-shell
        recent-items
        supergfxctl-gex
        wireless-hid
        vitals
        no-activities-button
        custom-hot-corners-extended
        hide-universal-access
        arrange-windows
        window-state-manager
        appindicator
        miniview
        alphabetical-app-grid
        color-picker

        (writeShellScriptBin "gnome-terminal" ''
          #!/bin/bash
          kitty $@
        '')
      ];
    };
  };
}
