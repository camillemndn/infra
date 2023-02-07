{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" ];
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/34223ccd-07a5-4c1c-b2d6-f49246dcb9a8";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/F33A-753F";
      fsType = "vfat";
    };

  swapDevices = [{ device = "/dev/disk/by-uuid/0f02375d-b47b-45c7-a0d3-391c39cb2570"; }];
}
