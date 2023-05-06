inputs: { config, pkgs, lib, ... }:

with lib;
with inputs;

{
  imports = [
    (import ../base inputs)
    # (import ../../modules/desktop/windowManagers/hyprland inputs)
  ];

  home = {
    packages = with pkgs; [
      (writeShellScriptBin "gnome-terminal" ''
        #!/bin/bash

        kitty $@
      '')

      lutris
      prismlauncher
      cemu

      signal-desktop-beta
      discord
      # caprine-bin
      # zapzap
      zoom-us

      libreoffice-fresh
      zotero
      xournalpp
      pdftocgen

      bitwarden
      bitwarden-cli
      joplin-desktop
      nextcloud-client
      # syncthingtray

      inkscape-with-extensions
      # digikam

      vlc
      jellyfin-media-player
      sonixd
      frescobaldi
      lilypond-with-fonts

      python3
      neomutt
    ];

    sessionVariables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";

    stateVersion = "23.05";
  };

  services = {
    nextcloud-client = {
      enable = true;
      #package = pkgs.owncloud-client;
      startInBackground = true;
    };

    syncthing = {
      # enable = true;
      # tray.enable = true;
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.services.nextcloud-client = {
    Service.ExecStartPre = mkForce "${pkgs.coreutils}/bin/sleep 5";
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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    thunderbird = {
      enable = true;
      package = pkgs.unstable-working.thunderbird;
      profiles."camille".isDefault = true;
    };
  };

  profiles.spicetify.enable = true;

  accounts.email.accounts."ENS" = {
    address = "camille.mondon@ens.fr";
    primary = true;
    userName = "cmondon02";

    imap = {
      host = "clipper.ens.fr";
      port = 993;
    };

    smtp = {
      host = "clipper.ens.fr";
      port = 465;
    };
  };

  #qt = {
  #  enable = true;
  #  platformTheme = "gnome";
  #  style.name = "adwaita-dark";
  #  style.package = pkgs.adwaita-qt;
  #};

  xdg.desktopEntries = {
    spotify.settings = {
      Type = "Application";
      Name = "Spotify";
      GenericName = "Music Player";
      Icon = "spotify-client";
      TryExec = "spotify";
      Exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=x11 %U";
      Terminal = "false";
      MimeType = "x-scheme-handler/spotify;";
      Categories = "Audio;Music;Player;AudioVideo;";
      StartupWMClass = "spotify";
    };

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
}
