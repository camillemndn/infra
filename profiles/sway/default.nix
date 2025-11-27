{
  config,
  lib,
  ...
}:

lib.mkIf config.programs.sway.enable {
  programs.sway.extraPackages = [ ];
  services.gnome.gnome-keyring.enable = true;
}
