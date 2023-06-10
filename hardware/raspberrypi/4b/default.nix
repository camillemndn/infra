{ lib, ... }:

with lib;

{
  boot = {
    loader = {
      grub.enable = false;
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    initrd = {
      availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
      kernelModules = [ ];

      zfs-ssh = {
        enable = true;
        kernelModule = "genet";
        keyType = "usb";
      };
    };
  };

  hardware.enableRedistributableFirmware = mkDefault true;

  powerManagement.cpuFreqGovernor = mkDefault "ondemand";

  fileSystems."/" =
    {
      device = "zroot/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zroot/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-id/mmc-SL32G_0x53df2d57-part3";
      fsType = "vfat";
      options = [ "X-mount.mkdir" ];
    };

  swapDevices = [{
    device = "/dev/disk/by-id/mmc-SL32G_0x53df2d57-part2";
    randomEncryption = true;
  }];
}
