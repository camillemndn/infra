{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "thelonious";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  deployment.allowLocalDeployment = true;

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
    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
        gutenprint
      ];
    };
    tailscale.enable = true;
    usbmuxd.enable = true;
    openssh.enable = true;
  };

  users.mutableUsers = true;
  users.users.camille.hashedPasswordFile = null;
  sops.secrets = { };

  system.stateVersion = "23.11";
}
