{ config, pkgs, ... }:

{
  networking = {
    hostName = "genesis";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nix-software-center
  ];

  nixpkgs.config.firefox = {
    ffmpegSupport = true;
    enableGnomeExtensions = true;
    enableFirefoxPwa = true;
  };

  profiles = {
    gdm.enable = true;
    gnome.enable = true;
    hyprland.enable = true;
  };

  programs = {
    firefox.enable = true;
    steam.enable = true;
    dconf.enable = true;
  };

  services = {
    logind.killUserProcesses = true;
    power-profiles-daemon.enable = false;
    printing = { enable = true; drivers = [ pkgs.brlaser ]; };
    tailscale.enable = true;
    tlp.enable = true;
  };

  sops.age.keyFile = "/home/camille/.config/sops/age/keys.txt";

  # virtualisation = {
  #   waydroid.enable = true;
  #   lxd.enable = true;
  # };

  system.stateVersion = "23.05";
}
