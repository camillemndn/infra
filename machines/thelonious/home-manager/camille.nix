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

  home.packages = with pkgs; [
    # Social
    mattermost-desktop
    signal-desktop
    zoom-us

    # Desk
    libreoffice-fresh
    pdftocgen
    xournalpp
    zotero

    # Sync
    bitwarden
    bitwarden-cli
    localsend

    # Graphics
    inkscape-with-extensions

    # Music & Video
    clapper
    spotify
  ];

  home.stateVersion = "23.11";
}
