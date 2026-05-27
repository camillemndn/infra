{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      android-tools
      dump-iphone-backup
      idevicerestore
      ifuse
      libimobiledevice
      libirecovery
      signalbackup-tools
    ];
  };

  hardware.sane = {
    enable = true;
    dsseries.enable = true;
  };
  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
  };
  programs = {
    firefox.enable = true;
    niri.enable = true;
    nixvim.enable = true;
    steam.enable = true;
    sway.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        cups-brother-hll2340dw
        samsung-unified-linux-driver
      ];
    };
    tzupdate.enable = true;
    usbmuxd.enable = true;
  };

  stylix.enable = true;

  system.stateVersion = "23.05";
}
