{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.kitty.enable {
  programs.kitty = {
    font = {
      name = "FiraCode Nerd Font Mono Reg";
      package = with pkgs; (nerdfonts.override { fonts = [ "FiraCode" ]; });
      size = lib.mkIf config.gtk.hidpi.enable 15;
    };

    themeFile = "Catppuccin-Mocha";

    settings = {
      wayland_titlebar_color = "background";
      background_opacity = "0.8";
    };
  };
}
