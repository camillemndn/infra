{ pkgs, lib, ... }:

with lib;

{
  home.packages = with pkgs; [
    # Games
    cemu
    lutris
    prismlauncher
    wineWow64Packages.waylandFull
    (retroarch.withCores (
      cores: with cores; [
        dolphin
        citra
      ]
    ))
    azahar

    # Social
    mattermost-desktop
    signal-desktop

    # Desk
    libreoffice-qt6-fresh
    pdftocgen
    xournalpp
    zotero

    # Tools
    ocrmypdf
    organize-tool
    pdfarranger

    # Sync
    bitwarden-cli
    bitwarden-desktop
    joplin-desktop
    localsend
    nextcloud-client
    qbittorrent
    tailscale-systray

    # Graphics
    darktable
    gimp3-with-plugins
    inkscape-with-extensions

    # Music & Video
    mpv
    harmony-assistant
    jellyfin-media-player
    lilypond-with-fonts
    musescore
    feishin
    spotify

    # Studio
    ardour
    drumgizmo
    gxplugins-lv2
    lenmus
    lmms
    lsp-plugins
    luppp
    tenacity
    zam-plugins
    zrythm
  ];

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    emacs.enable = true;
    kitty.enable = true;
    thunderbird.enable = true;
    waybar.bluetooth.enable = true;
  };

  services.nextcloud-client.enable = true;
  stylix.targets.fish.enable = false;
  wayland.windowManager.sway.enable = true;

  home.stateVersion = "23.05";
}
