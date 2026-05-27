{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.stylix.enable {
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    fonts = {
      serif = {
        name = "DejaVu Serif Condensed";
        package = pkgs.dejavu_fonts;
      };

      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };

      monospace = {
        name = "FiraCode Nerd Font Mono Reg";
        package = pkgs.nerd-fonts.fira-code;
      };

      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
    };

    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/orangci/walls-catppuccin-mocha/master/waves.png";
      hash = "sha256-I7RERKgoDsExGo6GjBKx0bOCkYlK+dgvlI29FHXA7AE=";
    };

    opacity = {
      terminal = 0.95;
      popups = 0.85;
    };

    polarity = "dark";

    targets.fish.enable = false;
  };
}
