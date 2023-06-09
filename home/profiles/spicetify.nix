{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.spicetify;
in
with lib;

{
  options.profiles.spicetify = {
    enable = mkEnableOption "Activate spicetify program";
  };

  config = mkIf cfg.enable {
    # nixpkgs.overlays = [ (final: prev: { spotify = prev.spotify.overrideAttrs { deviceScaleFactor = 3; }; }) ];
    programs.spicetify =
      {
        enable = true;
        theme = pkgs.spicetify-nix.themes.catppuccin-mocha;
        colorScheme = "flamingo";

        enabledExtensions = with pkgs.spicetify-nix.extensions; [
          fullAppDisplay
          shuffle # shuffle+ (special characters are sanitized out of ext names)
          #hidePodcasts
        ];
      };
  };
}
