{ config, pkgs, lib, ... }:

with lib;

{
  home = {
    packages = with pkgs; [
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

      # Graphics
      inkscape-with-extensions

      # Music & Video
      clapper
    ];
  };

  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs29-nox;
      extraPackages = e: with e;[
        quarto-mode
        catppuccin-theme
      ];
      extraConfig = ''
        (load-theme 'catppuccin :no-confirm)
      '';
    };

    thunderbird = { enable = true; profiles."camille".isDefault = true; };
  };

  profiles = {
    kitty.enable = true;
    hyprland.enable = true;
    neovim.full.enable = true;
    spotify.enable = true;
    sway.enable = true;
  };

  home.stateVersion = "23.11";
}
