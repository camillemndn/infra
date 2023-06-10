{ lib, ... }:

{
  home = {
    username = "camille";
    homeDirectory = "/home/camille";
    language.base = "fr";
    keyboard.layout = "fr";
    stateVersion = lib.mkDefault "22.11";
  };

  profiles.kitty.enable = true;

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.home-manager.enable = true;
}
