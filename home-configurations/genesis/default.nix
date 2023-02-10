{ config, pkgs, lib, ... }:

{
  imports = [ ../base ];

  home = {
    packages = with pkgs; [
      write_stylus
      minecraft
      digikam
      wine-wayland
      heroic
      joplin-desktop
      whatsapp-for-linux
      signal-desktop-beta
      libreoffice-fresh
      nextcloud-client
      inkscape-with-extensions
      vlc
      jellyfin-media-player
      sonixd
      spotify
      spotifywm
      frescobaldi
      lilypond-with-fonts
      python3
      neomutt
      zotero
      discord
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

    sonixd.settings = {
      Name = "Sonixd";
      Exec = "AppRun --no-sandbox %U";
      Terminal = "false";
      Type = "Application";
      Icon = "sonixd";
      StartupWMClass = "Sonixd";
      X-AppImage-Version = "0.15.3";
      Comment = "A full-featured Subsonic/Jellyfin compatible desktop client";
      Categories = "Development";
    };
  };
}
