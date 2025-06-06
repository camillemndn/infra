{
  config,
  lib,
  ...
}:

lib.mkIf config.programs.kitty.enable {
  programs.kitty.settings.wayland_titlebar_color = "background";
}
