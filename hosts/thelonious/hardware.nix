{ config, lib, ... }:

{
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    initrd = {
      luks = {
        devices = {
          "luks-c64c8ddc-e96f-453d-b445-98bef8fd0803".device =
            "/dev/disk/by-uuid/c64c8ddc-e96f-453d-b445-98bef8fd0803";

          "luks-0a53c761-f5d4-4015-9d68-349251b71c85".device =
            "/dev/disk/by-uuid/0a53c761-f5d4-4015-9d68-349251b71c85";
        };
      };

      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "tpm_tis"
      ];
    };

    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "tpm_tis.interrupts=0" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/959a07ef-a27d-4186-87da-9ed23dc4aa33";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/6851-8BFB";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/2deec870-eb12-4930-843f-c6603e27a424"; } ];

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    nvidia.open = true;
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
}
