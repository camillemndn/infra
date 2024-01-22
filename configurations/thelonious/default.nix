{ pkgs, ... }:

{
  networking = {
    hostName = "thelonious";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    firefoxpwa
    ifuse
    libimobiledevice
    libirecovery
    idevicerestore
  ];

  profiles = {
    browser.enable = true;
    gdm.enable = true;
    gnome.enable = true;
    hyprland.enable = true;
    sway.enable = true;
  };

  services = {
    logind.killUserProcesses = true;
    power-profiles-daemon.enable = false;
    printing = { enable = true; drivers = with pkgs; [ brlaser gutenprint ]; };
    tailscale.enable = true;
    usbmuxd.enable = true;
  };

  users.mutableUsers = true;
  users.users.camille.hashedPasswordFile = null;

  system.stateVersion = "23.11";
}
