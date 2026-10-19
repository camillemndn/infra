{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "usbhid"
    ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 2;
      };
    };
  };

  hardware.enableRedistributableFirmware = false;
  nixpkgs.hostPlatform = "aarch64-linux";
}
