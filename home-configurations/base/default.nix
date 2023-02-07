{ config, pkgs, lib, ... }:

{
  imports = import ../../home-modules;

  home = {
    username = "camille";
    homeDirectory = "/home/camille";
    keyboard.layout = "fr";
    stateVersion = lib.mkDefault "22.11";
  };

  profiles.neovim.enable = true;

  programs.home-manager.enable = true;
}
