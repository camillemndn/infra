{ config, pkgs, lib, ... }:

with lib;

{
  home = {
    packages = with pkgs; [
      # Games
      lutris
      prismlauncher-qt5
      dolphin-emu
      cemu
      citra-canary

      # Social
      signal-desktop-beta
      zoom-us

      # Desk
      libreoffice-fresh
      zotero
      xournalpp
      pdftocgen

      # Sync
      bitwarden
      bitwarden-cli
      joplin-desktop
      nextcloud-client

      # Graphics
      inkscape-with-extensions

      # Music & Video
      frescobaldi
      harmony-assistant
      jellyfin-media-player
      lilypond-with-fonts
      musescore
      sonixd
      vlc

      # Computer
      python3

      (writeShellScriptBin "gnome-terminal" ''
        #!/bin/bash
        kitty $@
      '')
    ];

    sessionVariables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";
  };

  services = {
    nextcloud-client = { enable = true; startInBackground = true; };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.services.nextcloud-client = {
    Service.ExecStartPre = mkForce "${pkgs.coreutils}/bin/sleep 10";
    Unit = {
      After = mkForce [ "org.gnome.Shell.target" ];
      PartOf = mkForce [ ];
    };
    Install.WantedBy = mkForce [ "org.gnome.Shell.target" ];
  };

  systemd.user.services.syncthingtray = mkIf config.services.syncthing.tray.enable {
    Service.ExecStartPre = mkForce "${pkgs.coreutils}/bin/sleep 5";
    Unit = {
      After = mkForce [ "org.gnome.Shell.target" ];
      PartOf = mkForce [ ];
      Requires = mkForce [ ];
    };
    Install.WantedBy = mkForce [ "org.gnome.Shell.target" ];
  };

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    thunderbird = {
      enable = true;
      profiles."camille".isDefault = true;
    };
  };

  profiles = {
    code.enable = true;
    kitty.enable = true;
    neovim.full.enable = true;
    spotify.enable = true;
  };

  xdg.desktopEntries = {
    "net.lutris.Lutris".settings = {
      Name = "Lutris";
      Comment = "Video Game Preservation Platform";
      Categories = "Game;";
      Keywords = "gaming;wine;emulator;";
      Exec = ''sh -c "xinput list --name-only | grep ^xwayland-pointer-gestures | xargs -n1 xinput disable; lutris %U"'';
      Icon = "lutris";
      Terminal = "false";
      Type = "Application";
      MimeType = "x-scheme-handler/lutris;";
      X-GNOME-UsesNotifications = "true";
    };

    xterm = {
      name = "";
      exec = "";
      noDisplay = true;
    };
  };

  home.stateVersion = "23.05";
}
