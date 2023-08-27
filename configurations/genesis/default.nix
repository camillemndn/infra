{ pkgs, ... }:

{
  networking = {
    hostName = "genesis";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    amdctl
    ifuse
    libimobiledevice
    nix-software-center
  ];

  nixpkgs.config.firefox = {
    enableFirefoxPwa = true;
    enableGnomeExtensions = true;
    ffmpegSupport = true;
  };

  profiles = {
    gdm.enable = true;
    gnome.enable = true;
  };

  programs = {
    dconf.enable = true;
    firefox.enable = true;
    steam.enable = true;
    sway = { enable = true; wrapperFeatures.gtk = true; };
  };
  services = {
    logind.killUserProcesses = true;
    power-profiles-daemon.enable = false;
    printing = { enable = true; drivers = with pkgs; [ brlaser gutenprint ]; };
    tailscale.enable = true;
    tlp.enable = true;
    udev.packages = [ pkgs.android-udev-rules ];
    usbmuxd.enable = true;
  };

  system.stateVersion = "23.05";
}
