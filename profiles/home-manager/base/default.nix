{ lib, pkgs, ... }:

{
  home = {
    keyboard.layout = "fr";
    language.base = "fr_FR.UTF-8";
    packages = [ pkgs.comma-with-db ];
    sessionVariables = {
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland";
    };
    stateVersion = lib.mkDefault "24.05";
  };

  programs = {
    fish.enable = true;
    home-manager.enable = true;

    nix-index = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.nix-index-with-db;
    };
  };
}
