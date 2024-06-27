{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.studio;
in
with lib;

{
  options.profiles.studio.enable = mkEnableOption "Activate studio";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ardour
      lmms
      zrythm
      lsp-plugins
      zam-plugins
      gxplugins-lv2
      luppp
      lenmus
      drumgizmo
    ];
  };
}
