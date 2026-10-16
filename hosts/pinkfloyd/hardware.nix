{
  config,
  lib,
  ...
}:

{
  boot = {
    lanzaboote.enable = true;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
      ];

      clevis = {
        enable = true;
        devices.crypted.secretFile = "${./luks.jwe}";
      };

      systemd.enable = true;
    };

    kernelModules = [ "kvm-amd" ];
  };

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = lib.mkDefault true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

}
