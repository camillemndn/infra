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
      emoji.package = pkgs.noto-fonts-color-emoji;

      monospace = {
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerd-fonts.fira-code;
      };

      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };

      serif = {
        name = "DejaVu Serif Condensed";
        package = pkgs.dejavu_fonts;
      };
    };

    image = pkgs.fetchurl {
      hash = "sha256-7yVwLqDaVGrHcICB5nTVn4Wjj/KdwgSGWdeTJZau+X4=";
      url = "https://raw.githubusercontent.com/orangci/walls-catppuccin-mocha/master/waves.png";
    };

    opacity = {
      popups = 0.85;
      terminal = 0.95;
    };

    polarity = "dark";

    targets = {
      fish.enable = false;
      # The overlay rebuilds gtksourceview's dependents; the home-manager target installs the scheme instead.
      gtksourceview.enable = false;
      qt.enable = false;
    };
  };
}
