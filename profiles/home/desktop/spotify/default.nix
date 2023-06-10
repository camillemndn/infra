{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.spotify;
in
with lib;

{
  options.profiles.spotify = {
    enable = mkEnableOption "Activate Spotify with Spicetify";
  };

  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      theme = pkgs.spicetify-nix.themes.catppuccin-mocha;
      colorScheme = "flamingo";

      enabledExtensions = with pkgs.spicetify-nix.extensions; [
        fullAppDisplay
        shuffle
      ];
    };

    xdg.desktopEntries = {
      spotify.settings = {
        Type = "Application";
        Name = "Spotify";
        GenericName = "Music Player";
        Icon = "spotify-client";
        TryExec = "spotify";
        Exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=x11 %U";
        Terminal = "false";
        MimeType = "x-scheme-handler/spotify;";
        Categories = "Audio;Music;Player;AudioVideo;";
        StartupWMClass = "spotify";
      };
    };
  };
}
