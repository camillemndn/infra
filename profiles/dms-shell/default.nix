{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.dms-shell.enable {
  environment.systemPackages = with pkgs; [
    dsearch
    yazi
  ];

  fonts.packages = with pkgs; [
    inter
    material-symbols
  ];

  programs.dms-shell = {
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
      target = "niri.service"; # Only auto-start in niri sessions, not Plasma/sway
    };
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
  };
}
