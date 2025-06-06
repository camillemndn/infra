{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.fuzzel.enable {

  programs.fuzzel = {
    settings = {
      main = {
        font = lib.mkForce "FiraCode Nerd Font Mono:size=10:style=Bold";
        dpi-aware = "yes";
        icon-theme = "Yaru";
        terminal = "${pkgs.kitty}/bin/kitty";
        lines = 10;
        horizontal-pad = 24;
        vertical-pad = 24;
        line-height = 24;
      };
    };
  };
}
