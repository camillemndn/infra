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
    };

    initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelPatches = [
      {
        name = "asus-rog-flow-x13-tablet-mode";
        patch = builtins.fetchurl {
          url = "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-6.1/0001-HID-amd_sfh-Add-support-for-tablet-mode-switch-senso.patch";
          sha256 = "sha256:08qw7qq88dy96jxa0f4x33gj2nb4qxa6fh2f25lcl8bgmk00k7l2";
        };
      }
    ];
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-dd5289a3-7499-4efe-8354-2bf713b672df".device = "/dev/disk/by-uuid/dd5289a3-7499-4efe-8354-2bf713b672df";
  boot.initrd.luks.devices."luks-dd5289a3-7499-4efe-8354-2bf713b672df".keyFile = "/crypto_keyfile.bin";

  hardware = {
    enableRedistributableFirmware = mkDefault true;
    cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    video.hidpi.enable = mkDefault true;
    sensor.iio.enable = true;
    opengl.enable = true;
    # nvidia.modesetting.enable = true;
    # nvidia.open = true;
    # nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    #nvidia.prime = {
    #  amdgpuBusId = "PCI:8:0:0";
    #  nvidiaBusId = "PCI:1:0:0";
    #};
  };

  environment.systemPackages = with pkgs; [ sbctl ];
  programs.xwayland.enable = true;
  services.asusd.enable = true;
  services.fprintd.enable = true;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/7bb7a74c-66f3-4d32-8502-edf64f52e23e";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-d0de046c-c584-4761-a3cb-66fc7a1802b8".device = "/dev/disk/by-uuid/d0de046c-c584-4761-a3cb-66fc7a1802b8";

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/A48C-7D48";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/985173da-9c6d-46e0-a04b-bbba9966f315"; }];
}
