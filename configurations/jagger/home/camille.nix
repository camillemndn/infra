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

      # Computer
      python3
    ];
  };

  services.nextcloud-client = { enable = true; startInBackground = true; };

  systemd.user.services.nextcloud-client.Service = {
    ExecStartPre = "${pkgs.coreutils}/bin/rm -rf %h/.local/share/Nextcloud";
    Restart = "on-failure";
    RestartSec = "5s";
  };

  programs = {
    chromium = { enable = true; package = pkgs.ungoogled-chromium; };
    thunderbird = { enable = true; profiles."camille".isDefault = true; };
  };

  profiles = {
    kitty.enable = true;
    hyprland.enable = true;
    neovim.full.enable = true;
    spotify.enable = true;
    studio.enable = true;
    sway.enable = true;
  };

  home.stateVersion = "23.05";
}
