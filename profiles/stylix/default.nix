{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.xserver;
in

lib.mkIf cfg.enable {
  stylix = {
    enable = true;
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
        name = "Fantasque Sans Mono";
        package = pkgs.nerd-fonts.fantasque-sans-mono;
      };

      monospace = {
        name = "FiraCode Nerd Font Mono Reg";
        package = pkgs.nerd-fonts.fira-code;
      };

      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji;
      };

      sizes = {
        terminal = lib.mkIf cfg.displayManager.gdm.hidpi.enable 15;
        applications = lib.mkIf cfg.displayManager.gdm.hidpi.enable 11;
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
  };
}
