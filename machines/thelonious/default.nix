{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "thelonious";
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [
        2022
        53317
      ];
      allowedUDPPorts = [ 53317 ];
    };
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
    nixvim.enable = true;
    sway.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    logind.killUserProcesses = true;
    openssh.enable = true;
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
  };

  stylix.enable = true;

  system.stateVersion = "23.11";
}
