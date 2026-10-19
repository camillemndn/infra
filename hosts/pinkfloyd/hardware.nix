{ inputs, pkgs, ... }:

{
  imports = [ "${inputs.lanzaboote}/nix/modules/lanzaboote.nix" ];

  boot = {
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
    };

    kernelModules = [ "kvm-amd" ];

    lanzaboote = {
      enable = true;
      configurationLimit = 5;
      package = (import inputs.lanzaboote { inherit (pkgs.stdenv.hostPlatform) system; }).packages.lzbt;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  hardware.bluetooth.enable = true;
}
