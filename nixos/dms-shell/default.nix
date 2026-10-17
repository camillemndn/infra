{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.dms-shell.enable {
  environment.systemPackages = with pkgs; [
    dsearch
    nemo
    yazi
  ];

  fonts.packages = with pkgs; [
    inter
    material-symbols
  ];

  programs.dms-shell = {
    systemd.target = "niri.service";
  };
}
