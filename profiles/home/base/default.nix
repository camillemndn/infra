{ lib, ... }:

{
  home = {
    language.base = "fr";
    keyboard.layout = "fr";
    stateVersion = lib.mkDefault "22.11";
  };

  profiles.neovim.enable = true;

  programs.fish.enable = true;

  programs.home-manager.enable = true;
}
