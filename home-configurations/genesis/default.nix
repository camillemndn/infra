{ config, pkgs, lib, ... }:

{
  imports = [ ../base ];

  home = {
    packages = with pkgs; [
      lutris
      prismlauncher

      zapzap
      signal-desktop-beta
      discord
      caprine-bin

      libreoffice-fresh
      write_stylus
      zotero

      joplin-desktop
      nextcloud-client

      inkscape-with-extensions
      digikam

      vlc
      jellyfin-media-player
      sonixd
      spotify
      spotifywm
      frescobaldi
      lilypond-with-fonts

      python3
      neomutt
    ];

    sessionVariables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";

    stateVersion = "23.05";
  };

  services = {
    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
    syncthing.enable = true;
  };

  programs = {
    thunderbird = {
      enable = true;
      profiles."camille".isDefault = true;
    };
  };

  accounts.email.accounts."ENS" = {
    address = "camille.mondon@ens.fr";
    primary = true;
    userName = "cmondon02";

    imap = {
      host = "clipper.ens.fr";
      port = 993;
    };

    smtp = {
      host = "clipper.ens.fr";
      port = 465;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };

  xdg.desktopEntries = {
    spotify.settings = {
      Type = "Application";
      Name = "Spotify";
      GenericName = "Music Player";
      Icon = "spotify-client";
      TryExec = "spotify";
      Exec = "spotify --force-device-scale-factor=3 %U";
      Terminal = "false";
      MimeType = "x-scheme-handler/spotify;";
      Categories = "Audio;Music;Player;AudioVideo;";
      StartupWMClass = "spotify";
    };

    xterm = {
      name = "";
      exec = "";
      noDisplay = true;
    };
  };
}
