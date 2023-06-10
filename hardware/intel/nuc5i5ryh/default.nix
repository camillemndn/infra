{ config, lib, ... }:

with lib;

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      zfs-ssh.enable = true;
    };

    kernelModules = [ "kvm-intel" ];
  };

  hardware = {
    enableRedistributableFirmware = mkDefault true;
    cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
  };

  fileSystems."/" =
    {
      device = "rpool/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-id/nvme-CT2000P2SSD8_2151E5F38722-part3";
      fsType = "vfat";
      options = [ "X-mount.mkdir" ];
    };

  swapDevices = [{
    device = "/dev/disk/by-id/nvme-CT2000P2SSD8_2151E5F38722-part2";
    randomEncryption = true;
  }];
}
