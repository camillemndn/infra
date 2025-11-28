{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e430dd5d-b2b0-475a-9a64-409032cf6e07";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6C60-B17F";
    fsType = "vfat";
  };

  fileSystems."/srv/media/Vidéos" = {
    device = "/dev/disk/by-uuid/aa257298-50dc-43b4-95d6-cc658c6777ad";
    fsType = "ext4";
    depends = [ "/dev/disk/by-uuid/e430dd5d-b2b0-475a-9a64-409032cf6e07" ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];
}
