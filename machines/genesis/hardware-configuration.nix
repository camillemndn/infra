{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 5;
    };

    loader.efi.canTouchEfiVariables = true;

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

      luks.devices = {
        luks-d0de046c-c584-4761-a3cb-66fc7a1802b8.device = "/dev/disk/by-uuid/d0de046c-c584-4761-a3cb-66fc7a1802b8";

        luks-dd5289a3-7499-4efe-8354-2bf713b672df = {
          device = "/dev/disk/by-uuid/dd5289a3-7499-4efe-8354-2bf713b672df";
          keyFile = "/crypto_keyfile.bin";
        };
      };

      secrets."/crypto_keyfile.bin" = null;
    };

    blacklistedKernelModules = [ "nouveau" ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "supergfxd.mode=integrated" ];

    tmp.cleanOnBoot = true;
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  environment.systemPackages = with pkgs; [
    amdctl
    asusctl
    bluetuith
    sbctl
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7bb7a74c-66f3-4d32-8502-edf64f52e23e";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A48C-7D48";
      fsType = "vfat";
    };
  };

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ libva-vdpau-driver ];
    };

    nvidia = {
      modesetting.enable = true;
      open = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = "PCI:8:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    sensor.iio.enable = true;
  };

  security = {
    rtkit.enable = true;
    pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
    ];
  };

  services = {
    asusd = {
      enable = true;
      fanCurvesConfig.source = ./fan_curves.ron;
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

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xserver.videoDrivers = [ "nvidia" ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/985173da-9c6d-46e0-a04b-bbba9966f315"; } ];

  systemd.services.supergfxd.path = [
    pkgs.kmod
    pkgs.pciutils
  ];
}
