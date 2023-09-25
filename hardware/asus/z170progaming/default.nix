{ config, lib, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 5;
    };

    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      systemd.enable = true;

      luks.devices = {
        "luks-90a7cca1-d6ee-48fb-b225-9519ad1e081b".device = "/dev/disk/by-uuid/90a7cca1-d6ee-48fb-b225-9519ad1e081b";

        "luks-3e4229db-fbe0-47f4-8f7c-285e2c55c268" = {
          device = "/dev/disk/by-uuid/3e4229db-fbe0-47f4-8f7c-285e2c55c268";
          keyFile = "/crypto_keyfile.bin";
        };
      };

      secrets."/crypto_keyfile.bin" = null;
    };

    kernelModules = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/60bbe830-38e3-4bf7-bd34-53b59e19f202";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/2503-8920";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/862328f8-8e9d-4c2e-ae74-b5dc73f940a1"; }];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  environment.systemPackages = with pkgs; [ sbctl ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
