{
  config,
  lib,
  ...
}:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
    };
    kernelModules = [ "kvm-intel" ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f89fec27-23d1-4899-92c7-91d77d666e6d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8ADB-5D04";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/5596fcb1-18b2-4313-a698-47bd996945e1"; }
  ];
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
