{ lib, pkgs, ... }:

{
  home = {
    language.base = "fr_FR.UTF-8";
    keyboard.layout = "fr";
    packages = [ pkgs.comma-with-db ];
  };

  profiles.neovim.enable = true;

  programs = {
    fish.enable = true;

    nix-index = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.nix-index-with-db;
    };

    home-manager.enable = true;
  };
}
