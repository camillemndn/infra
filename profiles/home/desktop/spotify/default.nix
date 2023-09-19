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
  };
}
