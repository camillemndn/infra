{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.xserver.desktopManager.gnome.enable {
  services.xserver = {
    enable = true;
    xkb = {
      layout = "fr";
      variant = "";
    };
  };

  hardware.pulseaudio.enable = false;

  programs.xwayland.enable = true;

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
    gnome.excludePackages =
      with pkgs;
      with gnome;
      [
        geary
        epiphany
        gnome-calendar
        gnome-console
      ];

    systemPackages =
      with pkgs;
      with gnome;
      with gnomeExtensions;
      [
        dconf-editor
        tailscale-status
        screen-rotate
        nextcloud-folder
        blur-my-shell
        recent-items
        supergfxctl-gex
        wireless-hid
        vitals
        hide-activities-button
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
}
