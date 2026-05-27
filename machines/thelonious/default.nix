{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  environment.systemPackages = with pkgs; [
    idevicerestore
    ifuse
    libimobiledevice
    libirecovery
  ];

  programs = {
    firefox.enable = true;
    niri.enable = true;
    nixvim.enable = true;
    sway.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    logind.settings.Login.KillUserProcesses = true;
    power-profiles-daemon.enable = false;
    printing.enable = true;
    usbmuxd.enable = true;
  };

  stylix.enable = true;

  system.stateVersion = "23.11";
}
