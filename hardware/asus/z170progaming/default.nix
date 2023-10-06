{ config, lib, pkgs, ... }:

{
  imports = [ ./clevis.nix ./luksroot.nix ];
  disabledModules = [ "system/boot/clevis.nix" "system/boot/luksroot.nix" ];

  boot = {
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 15;
    };

    initrd = {
      availableKernelModules = [ "e1000e" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "e1000e" ];

      clevis.enable = true;
      clevis.useTang = true;
      clevis.devices."luks-90a7cca1-d6ee-48fb-b225-9519ad1e081b".secretFile = ./luks.jwe;

      luks.devices = {
        "luks-90a7cca1-d6ee-48fb-b225-9519ad1e081b" = {
          device = "/dev/disk/by-uuid/90a7cca1-d6ee-48fb-b225-9519ad1e081b";
          fallbackToPassword = true;
          #crypttabExtraOpts = [ "_netdev" ];
        };
        "luks-3e4229db-fbe0-47f4-8f7c-285e2c55c268" = {
          device = "/dev/disk/by-uuid/3e4229db-fbe0-47f4-8f7c-285e2c55c268";
          keyFile = "/crypto_keyfile.bin";
          #crypttabExtraOpts = [ "_netdev" ];
        };
      };

      network.enable = true;
      secrets."/crypto_keyfile.bin" = null;
      systemd = {
        #enable = true;
        network = {
          enable = true;
          wait-online.enable = true;

          #networks."10-static" = {
          #  matchConfig.Name = [ "en*" "eth*" ];
          #  DHCP = "no";
          #  address = [ "192.168.1.4/24" ];
          #  linkConfig.RequiredForOnline = true;
          #  networkConfig.IPv6PrivacyExtensions = "kernel";
          #};
        };
      };
    };

    kernelModules = [ ];
    kernelParams = [
      #"ip=dhcp"
      #"ip=enp0s31f6:dhcp"
      "ip=192.168.1.3:::255.255.255.0::enp0s31f6:none"
    ];
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

  hardware.pulseaudio.enable = false;
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [ sbctl ];
  networking.useDHCP = lib.mkDefault true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
