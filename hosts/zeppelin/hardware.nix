{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];

    kernel.sysctl."vm.swappiness" = 1;

    loader = {
      systemd-boot.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      options = [ "noatime" ];
      device = "/dev/disk/by-uuid/e430dd5d-b2b0-475a-9a64-409032cf6e07";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/6C60-B17F";
      fsType = "vfat";
    };

    "/srv/media/Vidéos" = {
      depends = [ "/dev/disk/by-uuid/e430dd5d-b2b0-475a-9a64-409032cf6e07" ];
      device = "/dev/disk/by-uuid/aa257298-50dc-43b4-95d6-cc658c6777ad";
      fsType = "ext4";
    };
  };

  hardware.enableRedistributableFirmware = false;

  networking = {
    networkmanager.enable = false;
    useDHCP = false;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];

  systemd.network = {
    enable = true;

    networks."10-wan" = {
      address = [ "192.168.0.137/21" ];
      linkConfig.RequiredForOnline = "routable";
      matchConfig.Type = "ether";
      routes = [ { Gateway = "192.168.0.1"; } ];
    };
  };
}
