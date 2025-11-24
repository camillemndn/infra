{ pkgs, lib, ... }:

with lib;

{
  wayland.windowManager = {
    hyprland.enable = true;
    sway.enable = true;
  };

  programs = {
    emacs.enable = true;
    kitty.enable = true;
    neovim.full.enable = true;
    thunderbird.enable = true;
  };

  stylix.targets.fish.enable = false;

  home.packages = with pkgs; [
    # Social
    mattermost-desktop
    signal-desktop
    zoom-us

    # Desk
    libreoffice-qt6-fresh
    pdftocgen
    xournalpp
    zotero

    # Sync
    bitwarden
    bitwarden-cli
    localsend
    tailscale-systray

    # Graphics
    inkscape-with-extensions

    # Music & Video
    feishin
    mpv
    spotify
  ];

  home.stateVersion = "23.11";
}
