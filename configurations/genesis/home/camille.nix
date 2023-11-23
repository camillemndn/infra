{ config, pkgs, lib, ... }:

with lib;

{
  home = {
    packages = with pkgs; [
      # Games
      cemu
      lutris
      prismlauncher-qt5
      (retroarch.override { cores = with libretro; [ dolphin citra ]; })

      # Social
      mattermost-desktop
      signal-desktop
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
      clapper

      # Studio
      ardour
      lmms
      zrythm
      lsp-plugins
      zam-plugins
      gxplugins-lv2
      luppp
      lenmus

      # Computer
      python3
    ];
  };

  services = {
    easyeffects.enable = true;
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
      package = pkgs.thunderbird;
      profiles."camille".isDefault = true;
    };
  };

  profiles = {
    kitty.enable = true;
    gtk-qt.hidpi.enable = true;
    neovim.full.enable = true;
    spotify.enable = true;
    sway.enable = true;
  };

  home.stateVersion = "23.05";
}
