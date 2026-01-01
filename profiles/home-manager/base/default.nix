{ lib, pkgs, ... }:

let
  gtkConfig = {
    gtk-decoration-layout = "icon:minimize,maximize,close";
  };
in

{
  gtk = {
    gtk3.extraConfig = gtkConfig;
    gtk4.extraConfig = gtkConfig;
  };

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
