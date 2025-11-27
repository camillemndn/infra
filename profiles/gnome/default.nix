{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.desktopManager.gnome.enable {
  services.pulseaudio.enable = false;

  environment = {
    gnome.excludePackages = with pkgs; [
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
        pkgs.dconf-editor
        alphabetical-app-grid
        appindicator
        arrange-windows
        blur-my-shell
        color-picker
        custom-hot-corners-extended
        gpu-supergfxctl-switch
        hide-activities-button
        hide-universal-access
        miniview
        screen-rotate
        tailscale-status
        vitals
        window-state-manager
        wireless-hid

        (writeShellScriptBin "gnome-terminal" ''
          #!/bin/bash
          kitty $@
        '')
      ];
  };
}
