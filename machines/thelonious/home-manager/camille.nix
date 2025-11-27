{ pkgs, lib, ... }:

with lib;

{
  home.packages = with pkgs; [
    # Social
    mattermost-desktop
    signal-desktop

    # Desk
    libreoffice-qt6-fresh
    pdftocgen
    xournalpp
    zotero

    # Sync
    bitwarden-cli
    bitwarden-desktop
    localsend
    tailscale-systray

    # Graphics
    inkscape-with-extensions

    # Music & Video
    feishin
    mpv
    spotify
  ];

  programs = {
    emacs.enable = true;
    kitty.enable = true;
    neovim.full.enable = true;
    thunderbird.enable = true;
  };

  stylix.targets.fish.enable = false;
  wayland.windowManager.sway.enable = true;

  home.stateVersion = "23.11";
}
