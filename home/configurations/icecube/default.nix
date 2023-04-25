inputs: { config, pkgs, lib, ... }:

{
  home = {
    username = "camille";
    homeDirectory = "/home/camille";

    keyboard.layout = "fr";

    packages = with pkgs; [
      gnome.nautilus
      gnome.sushi # GNOME
      rofi # i3
      killall
      zip
      unzip
      evince
      flameshot
      htop # Tools
      inkscape-with-extensions
      imagemagick
      feh
      vlc
      jellyfin-media-player
      sonixd
      frescobaldi
      lilypond-with-fonts # Media
      meld
      python3
      ctags
      eternal-terminal # Coding
      blueman
      networkmanagerapplet
      firefox
      neomutt # Internet
      # sageWithDoc # Maths
    ];

    stateVersion = "22.11";
  };

  fonts.fontconfig.enable = true;

  xsession.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style.package = pkgs.adwaita-qt;
    style.name = "adwaita-dark";
  };

  gtk = {
    enable = true;
    font.name = "Ubuntu";
    cursorTheme.name = "Yaru";
    theme.name = "Yaru-dark";
    theme.package = pkgs.yaru-theme;
    iconTheme.name = "Yaru-dark";
    iconTheme.package = pkgs.yaru-theme;
  };

  xdg.desktopEntries = {
    "picom" = {
      name = "";
      exec = "";
      noDisplay = true;
    };
    "xterm" = {
      name = "";
      exec = "";
      noDisplay = true;
    };
    "sonixd" = {
      name = "Sonixd";
      exec = "sonixd";
      icon = "spotify";
    };
    "spotify" = {
      name = "Spotify";
      exec = "spotify --force-device-scale-factor=3 %U";
      icon = "spotify-client";
    };
  };

  programs.home-manager.enable = true;
}
