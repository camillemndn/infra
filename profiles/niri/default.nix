{
  config,
  lib,
  ...
}:

lib.mkIf config.programs.niri.enable {
  services.gnome.gnome-keyring.enable = true;
}
