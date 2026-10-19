{ inputs, pkgs, ... }:

{
  imports = [ "${inputs.lanzaboote}/nix/modules/lanzaboote.nix" ];

  boot = {
    blacklistedKernelModules = [ "nouveau" ];

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

    kernelModules = [ "kvm-amd" ];

    lanzaboote = {
      enable = true;
      configurationLimit = 5;
      package = (import inputs.lanzaboote { inherit (pkgs.stdenv.hostPlatform) system; }).packages.lzbt;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  environment.systemPackages = with pkgs; [
    amdctl
    bluetuith
    nvtopPackages.full
    sbctl
  ];

  hardware = {
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ libva-vdpau-driver ];
    };

    nvidia = {
      open = true;

      prime = {
        amdgpuBusId = "PCI:8:0:0";
        nvidiaBusId = "PCI:1:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };

    sensor.iio.enable = true;
  };

  services = {
    asusd.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;

    supergfxd = {
      enable = true;

      settings = {
        always_reboot = false;
        hotplug_type = "Asus";
        logout_timeout_s = 180;
        mode = "Integrated";
        no_logind = true;
        vfio_enable = false;
        vfio_save = false;
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
