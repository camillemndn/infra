{ config, lib, pkgs, ... }:

{
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      enrollKeys = true;
      configurationLimit = 10;
    };

    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };

  environment.systemPackages = [ pkgs.sbctl ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/dc9ab470-b542-43c3-bf54-a438d71b33a5";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9DEF-35FE";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/fadaee1c-9820-4c06-a144-f3d293e0a4e3"; }];
}
