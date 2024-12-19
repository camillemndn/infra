{ pkgs, lib, ... }:

with lib;

{
  wayland.windowManager = {
    hyprland.enable = true;
    sway.enable = true;
  };

  gtk.hidpi.enable = true;

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [ "--force-device-scale-factor=1.5" ];
    };

    emacs.enable = true;
    kitty.enable = true;
    neovim.full.enable = true;
    thunderbird.enable = true;
    waybar.bluetooth.enable = true;
  };

  services.nextcloud-client.enable = true;

  home.packages = with pkgs; [
    # Games
    cemu
    unstable.lutris
    prismlauncher
    wineWow64Packages.waylandFull
    (retroarch.override {
      cores = with libretro; [
        dolphin
        citra
      ];
    })
    ryujinx
    lime3ds

    # Social
    mattermost-desktop
    signal-desktop
    zoom-us

    # Desk
    gscan2pdf
    libreoffice-fresh
    pdftocgen
    xournalpp
    zotero

    # Sync
    bitwarden
    bitwarden-cli
    joplin-desktop
    localsend
    nextcloud-client
    qbittorrent

    # Graphics
    gimp-with-plugins
    inkscape-with-extensions

    # Music & Video
    clapper
    frescobaldi
    harmony-assistant
    jellyfin-media-player
    lilypond-with-fonts
    musescore
    sonixd
    spotify

    # Studio
    ardour
    lmms
    zrythm
    lsp-plugins
    zam-plugins
    gxplugins-lv2
    luppp
    lenmus
    drumgizmo
  ];

  home.stateVersion = "23.05";
}
