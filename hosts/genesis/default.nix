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

  fonts.packages = with pkgs; [
    caladea
    carlito
    ibm-plex
    jetbrains-mono
    liberation_ttf
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    roboto
    roboto-slab
    source-code-pro
    source-sans
    source-serif
  ];

  hardware.sane = {
    enable = true;
    dsseries.enable = true;
  };

  programs = {
    dms-shell.enable = true;
    firefox.enable = true;
    niri.enable = true;
    nixvim.enable = true;
    steam.enable = true;
    sway.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
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
