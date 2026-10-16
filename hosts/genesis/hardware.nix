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

    lanzaboote.enable = true;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "tpm_crb"
      ];

      clevisLuksAskpass.enable = true;

      secrets."/crypto_keyfile.bin" = null;
    };

    blacklistedKernelModules = [ "nouveau" ];
    kernelModules = [ "kvm-amd" ];

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
    nvtopPackages.full
    sbctl
  ];

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
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:8:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    sensor.iio.enable = true;
  };

  security = {
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
    asusd.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    pipewire.jack.enable = true;

    power-profiles-daemon.enable = true;
    supergfxd = {
      enable = true;
      settings = {
        mode = "Integrated";
        vfio_enable = false;
        vfio_save = false;
        always_reboot = false;
        no_logind = true;
        logout_timeout_s = 180;
        hotplug_type = "Asus";
      };
    };

    xserver.videoDrivers = [
      "amdgpu"
      "nvidia"
    ];
  };

  systemd = {
    services = {
      asusd.postStart = ''
        busctl set-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform PlatformProfileOnAc u 2
      '';
      supergfxd.serviceConfig.ExecStartPre = pkgs.writeShellScript "wait-igpu-panel" ''
        for _ in $(seq 100); do
          grep -qs connected /sys/class/drm/card*-eDP-1/status && exit 0
          sleep 0.1
        done
      '';
    };
  };

}
