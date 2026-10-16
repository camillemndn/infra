{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 2;
      };
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "usbhid"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-linux";
}
