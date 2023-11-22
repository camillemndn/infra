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
      configurationLimit = 15;
    };

    initrd = {
      availableKernelModules = [ "e1000e" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      clevis = { enable = true; useTang = true; devices.luks-90a7cca1-d6ee-48fb-b225-9519ad1e081b.secretFile = ./luks.jwe; };
      network.enable = true;
      secrets."/crypto_keyfile.bin" = null;

      luks.devices = {
        luks-90a7cca1-d6ee-48fb-b225-9519ad1e081b = {
          device = "/dev/disk/by-uuid/90a7cca1-d6ee-48fb-b225-9519ad1e081b";
        };
        luks-3e4229db-fbe0-47f4-8f7c-285e2c55c268 = {
          device = "/dev/disk/by-uuid/3e4229db-fbe0-47f4-8f7c-285e2c55c268";
          keyFile = "/crypto_keyfile.bin";
        };
      };

      systemd = {
        enable = true;

        network = {
          enable = true;
          wait-online.enable = true;
          networks."10-wan" = {
            matchConfig.Type = "ether";
            networkConfig.DHCP = "ipv4";
          };
        };
      };
    };
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

  musnix.enable = true;
  hardware.pulseaudio.enable = false;
  sound.enable = true;
  security.rtkit.enable = true;
  security.pam.loginLimits = lib.mkForce [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
    { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
    { domain = "@audio"; item = "nofile"; type = "hard"; value = "524288"; }
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [ sbctl ];
  networking.useDHCP = lib.mkDefault true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
