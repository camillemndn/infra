{ lib, pkgs, ... }:

let
  gtkConfig = {
    gtk-decoration-layout = "icon:minimize,maximize,close";
  };
in

{
  gtk = {
    gtk3.extraConfig = gtkConfig;
    gtk4 = {
      theme = null;
      extraConfig = gtkConfig;
    };
  };

  home = {
    keyboard.layout = "fr";
    language.base = "fr_FR.UTF-8";
    packages = [ pkgs.comma-with-db ];
    sessionVariables = {
      # GDK_BACKEND must NOT be forced here: xdg-desktop-portal-gnome
      # refuses to expose ScreenCast / Screenshot when GDK_BACKEND is
      # set ("Non-compatible display server, exposing settings only").
      # Modern GTK picks wayland automatically when XDG_SESSION_TYPE=wayland.
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

  services.random-background = {
    enable = true;
    imageDirectory =
      (builtins.fetchGit {
        url = "https://github.com/orangci/walls-catppuccin-mocha/";
        rev = "7bfdf10d16ad3a689f9f0cf3a0930da3d1a245a8";
      }).outPath;
  };
}
