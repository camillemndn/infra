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
    systemd = {
      enable = true;
      restartIfChanged = true;
      target = "niri.service";
    };
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
  };
}
