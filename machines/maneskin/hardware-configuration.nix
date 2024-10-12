{ lib, pkgs, ... }:

{
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    initrd.availableKernelModules = [
      "pcie_brcmstb"
      "reset-raspberrypi"
      "usbhid"
      "usb_storage"
      "vc4"
    ];

    kernelPackages = pkgs.unstable.linuxPackages_rpi4;
  };

  environment.systemPackages = [ pkgs.unstable.raspberrypi-eeprom ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
