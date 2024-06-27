{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 5;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "tpm_crb"
      ];
      clevis = {
        enable = true;
        devices.luks-d0de046c-c584-4761-a3cb-66fc7a1802b8.secretFile = ./luks.jwe;
      };
      secrets."/crypto_keyfile.bin" = null;

      luks.devices = {
        luks-d0de046c-c584-4761-a3cb-66fc7a1802b8.device = "/dev/disk/by-uuid/d0de046c-c584-4761-a3cb-66fc7a1802b8";

        luks-dd5289a3-7499-4efe-8354-2bf713b672df = {
          device = "/dev/disk/by-uuid/dd5289a3-7499-4efe-8354-2bf713b672df";
          keyFile = "/crypto_keyfile.bin";
        };
      };
    };

    blacklistedKernelModules = [ "nouveau" ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.pinned.linuxPackages;
    kernelParams = [ "supergfxd.mode=integrated" ];

    kernelPatches = [
      {
        name = "asus-rog-flow-x13-tablet-mode";
        patch = builtins.fetchurl {
          url = "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-6.8/amd-tablet-sfh.patch";
          sha256 = "011b4q0v8mkfrv96d4bvg8fd5dg6y5q38w20qmf196hsx35r13sh";
        };
      }
    ];

    tmp.cleanOnBoot = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7bb7a74c-66f3-4d32-8502-edf64f52e23e";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-uuid/A48C-7D48";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/985173da-9c6d-46e0-a04b-bbba9966f315"; } ];

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  environment.systemPackages = with pkgs; [
    sbctl
    bluetuith
  ];

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

  security.rtkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services = {
    asusd = {
      enable = true;
      fanCurvesConfig = readFile ./fan_curves.ron;
    };
    fprintd.enable = true;
    logiops.enable = true;

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

  systemd.services.supergfxd.path = [
    pkgs.kmod
    pkgs.pciutils
  ];
}
