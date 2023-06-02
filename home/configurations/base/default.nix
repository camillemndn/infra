inputs: { lib, ... }:

with inputs;

{
  imports = import ../../modules
    ++ import ../../profiles
    ++ [
    spicetify-nix.homeManagerModule
  ];

  home = {
    username = "camille";
    homeDirectory = "/home/camille";
    language.base = "fr";
    keyboard.layout = "fr";
    stateVersion = lib.mkDefault "22.11";
  };


  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  profiles.kitty.enable = true;

  programs.home-manager.enable = true;
}
