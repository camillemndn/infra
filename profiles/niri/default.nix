{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.niri.enable {
  programs.niri.package = pkgs.niri;
  services.gnome.gnome-keyring.enable = true;
  stylix.targets.qt.platform = lib.mkForce "qtct";
}
