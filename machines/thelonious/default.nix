{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "thelonious";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  deployment = {
    allowLocalDeployment = true;
    targetHost = lib.infra.machines.thelonious.ipv4.vpn;
  };

  environment.systemPackages = with pkgs; [
    idevicerestore
    ifuse
    libimobiledevice
    libirecovery
  ];

  programs = {
    firefox.enable = true;
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
    xserver.desktopManager.gnome.enable = true;
    xserver.displayManager.gdm.enable = true;
  };

  system.stateVersion = "23.11";
}
