{ config, lib, pkgs, ... }:

with lib;

{
  boot = {
    loader = {
      systemd-boot.enable = mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    lanzaboote = {
      enable = true;
      publicKeyFile = "/etc/secureboot/keys/db/db.pem"; # DB public key
      privateKeyFile = "/etc/secureboot/keys/db/db.key"; # DB private key
      pkiBundle = "/etc/secureboot/";
      enrollKeys = true;
      configurationLimit = 5;
    };

    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
      systemd.enable = true;

      # Setup keyfile
      secrets."/crypto_keyfile.bin" = null;

      # Enable swap on luks
      luks.devices = {
        "luks-d0de046c-c584-4761-a3cb-66fc7a1802b8".device = "/dev/disk/by-uuid/d0de046c-c584-4761-a3cb-66fc7a1802b8";

        "luks-dd5289a3-7499-4efe-8354-2bf713b672df" = {
          device = "/dev/disk/by-uuid/dd5289a3-7499-4efe-8354-2bf713b672df";
          keyFile = "/crypto_keyfile.bin";
        };
      };
    };

    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "nouveau" ];
    kernelPackages = pkgs.pinned.linuxPackages;
    kernelParams = [ "supergfxd.mode=integrated" ];

    kernelPatches = [{
      name = "asus-rog-flow-x13-tablet-mode";
      patch = builtins.fetchurl {
        url = "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-6.1/0001-HID-amd_sfh-Add-support-for-tablet-mode-switch-senso.patch";
        sha256 = "sha256:08qw7qq88dy96jxa0f4x33gj2nb4qxa6fh2f25lcl8bgmk00k7l2";
      };
    }];
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  environment.systemPackages = with pkgs; [ sbctl ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    sensor.iio.enable = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiVdpau ];
    };

    nvidia = {
      modesetting.enable = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = "PCI:8:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # Enable sound
  hardware.pulseaudio.enable = false;
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services = {
    asusd = {
      enable = true;
      fanCurvesConfig = readFile ./fan_curves.ron;
    };
    fprintd.enable = true;

    supergfxd = {
      enable = true;
      settings = {
        mode = "Integrated";
        vfio_enable = false;
        vfio_save = false;
        always_reboot = false;
        no_logind = false;
        logout_timeout_s = 10;
        hotplug_type = "Asus";
      };
    };

    xserver.videoDrivers = [ "nvidia" ];
  };

  systemd.services.supergfxd.path = [ pkgs.kmod pkgs.pciutils ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7bb7a74c-66f3-4d32-8502-edf64f52e23e";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/A48C-7D48";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/985173da-9c6d-46e0-a04b-bbba9966f315";
  }];
}
