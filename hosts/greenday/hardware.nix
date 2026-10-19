_:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
    };

    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];

    kernelModules = [ "kvm-intel" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/dca35e5c-eeb7-4b97-89aa-8a35538aa443";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/D876-A829";
      fsType = "vfat";

      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  powerManagement.enable = false;
}
