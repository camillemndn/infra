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

  profiles = {
    gdm = { enable = true; hidpi.enable = true; };
    gnome.enable = true;
    hyprland.enable = true;
    sway.enable = true;
  };

  programs = {
    dconf.enable = true;
    firefox.enable = true;
    steam.enable = true;
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
