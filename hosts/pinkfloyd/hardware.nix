{ inputs, pkgs, ... }:

{
  imports = [ "${inputs.lanzaboote}/nix/modules/lanzaboote.nix" ];

  boot = {
    lanzaboote = {
      enable = true;
      package = (import inputs.lanzaboote { inherit (pkgs.stdenv.hostPlatform) system; }).packages.lzbt;
      configurationLimit = 5;
      pkiBundle = "/var/lib/sbctl";
    };

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
  };

  hardware.bluetooth.enable = true;
}
