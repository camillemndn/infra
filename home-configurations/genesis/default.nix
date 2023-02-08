{ config, pkgs, lib, ... }:

let
  qpageview = pkgs.callPackage ./test.nix { };
  kms.frescobaldi = pkgs.frescobaldi.overrideAttrs (old: {
    version = "3.2";
    src = pkgs.fetchFromGitHub {
      owner = "wbsoft";
      repo = "frescobaldi";
      rev = "v3.2";
      sha256 = "sha256-q340ChF7VZcbLMW/nd1so7WScsPfbdeJUjTzsY5dkec=";
    };
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ qpageview ];
  });
in

{
  imports = [ ../base ];

  qt = {
    enable = true;
    platformTheme = "gnome";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };

  home = {
    packages = with pkgs; [
      # killall # Tools
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
      kms.frescobaldi
      lilypond-with-fonts # Media
      python3 # Coding
      neomutt # Internet
      zotero
      discord
      # sageWithDoc # Maths
    ];

    sessionVariables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";

    stateVersion = "23.05";
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

  services = {
    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };

  programs = {
    thunderbird = {
      # enable = true;
      profiles."camille".isDefault = true;
    };
  };
}
