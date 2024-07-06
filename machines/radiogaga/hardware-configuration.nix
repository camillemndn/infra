{ lib, pkgs, ... }:

with lib;

{
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    kernelPackages = pkgs.unstable.linuxPackages_rpi3;
  };

  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  hardware.enableRedistributableFirmware = mkDefault true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    systemWide = true;
  };

  powerManagement.cpuFreqGovernor = mkDefault "ondemand";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  networking.useDHCP = mkDefault false;
  networking.interfaces.eth0.useDHCP = mkDefault true;
  networking.interfaces.wlan0.useDHCP = mkDefault true;
}
