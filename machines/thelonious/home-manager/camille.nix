{ pkgs, lib, ... }:

with lib;

{
  wayland.windowManager.hyprland.enable = true;

  profiles = {
    kitty.enable = true;
    mail.enable = true;
    neovim.full.enable = true;
    spotify.enable = true;
    sway.enable = true;
  };

  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs29-nox;
      extraPackages =
        e: with e; [
          quarto-mode
          catppuccin-theme
        ];
      extraConfig = ''
        (load-theme 'catppuccin :no-confirm)
      '';
    };
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

    # Graphics
    inkscape-with-extensions

    # Music & Video
    clapper
  ];

  home.stateVersion = "23.11";
}
