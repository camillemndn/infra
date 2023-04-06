{ config, pkgs, lib, ... }:

{
  imports = import ../../modules;

  home = {
    username = "camille";
    homeDirectory = "/home/camille";
    language.base = "fr";
    keyboard.layout = "fr";
    stateVersion = lib.mkDefault "22.11";
  };

  profiles.neovim.enable = true;

  programs.home-manager.enable = true;
}
