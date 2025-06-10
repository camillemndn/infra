{ lib, pkgs, ... }:

{
  home = {
    keyboard.layout = "fr";
    language.base = "fr_FR.UTF-8";
    packages = [ pkgs.comma-with-db ];
    stateVersion = lib.mkDefault "24.05";
  };

  programs = {
    fish.enable = true;
    home-manager.enable = true;
    neovim.enable = true;

    nix-index = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.nix-index-with-db;
    };
  };

  stylix.targets.fish.enable = false;
}
