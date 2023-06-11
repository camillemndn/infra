{ lib, ... }:

{
  home = {
    language.base = "fr";
    keyboard.layout = "fr";
    stateVersion = lib.mkDefault "22.11";
  };

  profiles.neovim.enable = true;

  programs = {
    fish.enable = true;

    nix-index.enable = true;
    nix-index-database.comma.enable = true;

    home-manager.enable = true;
  };
}
