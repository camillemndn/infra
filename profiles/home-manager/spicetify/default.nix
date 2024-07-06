{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.spicetify.enable {
  programs.spicetify = {
    theme = pkgs.spicetify-nix.themes.catppuccin;
    colorScheme = "flamingo";

    enabledExtensions = with pkgs.spicetify-nix.extensions; [
      fullAppDisplay
      shuffle
    ];
  };
}
