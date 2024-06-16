{ pkgs, ... }:

{
  networking = {
    hostName = "jagger";
  };

  environment.systemPackages = with pkgs; [
    amdctl
    ifuse
    libimobiledevice
    nix-software-center
  ];

  profiles = {
    browser.enable = true;
    gdm.enable = true;
    gnome.enable = true;
    hyprland.enable = true;
    sway.enable = true;
  };

  programs.steam.enable = true;

  services = {
    logind.killUserProcesses = true;
    power-profiles-daemon.enable = false;
    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
        gutenprint
      ];
    };
    tailscale.enable = true;
    tlp.enable = true;
    udev.packages = [ pkgs.android-udev-rules ];
    usbmuxd.enable = true;
  };

  users.mutableUsers = true;
  users.users.camille.hashedPasswordFile = null;

  system.stateVersion = "23.05";
}
