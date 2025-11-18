{ pkgs, lib, ... }:

with lib;

{
  wayland.windowManager = {
    hyprland.enable = true;
    sway.enable = true;
  };

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [ "--force-device-scale-factor=1.5" ];
    };

    emacs.enable = true;
    kitty.enable = true;
    thunderbird.enable = true;
    waybar.bluetooth.enable = true;
  };

  services.nextcloud-client.enable = true;
  stylix.targets.fish.enable = false;

  home.packages = with pkgs; [
    # Games
    cemu
    unstable.lutris
    prismlauncher
    wineWow64Packages.waylandFull
    (retroarch.withCores (
      cores: with cores; [
        dolphin
        citra
      ]
    ))
    ryujinx
    azahar

    # Social
    mattermost-desktop
    signal-desktop
    zoom-us

    # Desk
    libreoffice-fresh
    pdftocgen
    xournalpp
    zotero

    # Tools
    ocrmypdf
    organize-tool
    pdfarranger

    # Sync
    bitwarden
    bitwarden-cli
    joplin-desktop
    localsend
    nextcloud-client
    qbittorrent

    # Graphics
    darktable
    gimp-with-plugins
    inkscape-with-extensions

    # Music & Video
    mpv
    frescobaldi
    harmony-assistant
    jellyfin-media-player
    lilypond-with-fonts
    musescore
    sonixd
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

  home.stateVersion = "23.05";
}
