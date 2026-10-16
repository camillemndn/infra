{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    ./disko.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 5;
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

      systemd.enable = true;
    };

    kernelModules = [ "kvm-amd" ];
    loader.efi.canTouchEfiVariables = true;
  };

  hardware = {
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
