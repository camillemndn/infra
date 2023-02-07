{ config, lib, pkgs, modulesPath, ... }:

with lib;

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };

    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  };

  hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/e430dd5d-b2b0-475a-9a64-409032cf6e07";
      fsType = "ext4";
    };

  fileSystems."/srv/media/Vidéos" =
    {
      device = "/dev/disk/by-uuid/aa257298-50dc-43b4-95d6-cc658c6777ad";
      fsType = "ext4";
    };

  swapDevices = [ ];

  networking.useDHCP = mkDefault false;
  networking.interfaces.ens18.useDHCP = mkDefault true;
}
