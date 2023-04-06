{ lib, ... }:

{
  imports = import ../../modules ++ import ../../profiles;

  home = {
    username = "camille";
    homeDirectory = "/home/camille";
    language.base = "fr";
    keyboard.layout = "fr";
    stateVersion = lib.mkDefault "22.11";
  };

  profiles.neovim.enable = true;
  profiles.kitty.enable = true;

  programs.home-manager.enable = true;
}
