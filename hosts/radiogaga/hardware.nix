{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ "${inputs.nixos-hardware}/raspberry-pi/3" ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    # VC4 needs the HDMI DDC adapter before taking over the boot framebuffer.
    initrd.kernelModules = [ "i2c-bcm2835" ];
    # Linux uses its matching mainline device trees; firmware DTBs serve U-Boot.
    loader.generic-extlinux-compatible.useGenerationDeviceTree = true;
  };

  hardware = {
    bluetooth.enable = true;
    # nixos-hardware ships the Wi-Fi/Bluetooth firmware; nothing else on the board loads any.
    enableRedistributableFirmware = false;

    # Let nixos-hardware manage config.txt, firmware, overlays and U-Boot.
    raspberry-pi.firmware = {
      enable = true;

      # Keep the 3B/3B+ device trees and overlays; omit other boards' DTBs
      # and Pi 4 boot firmware to fit the 30 MiB partition during updates.
      package = pkgs.runCommand "raspberrypi3-firmware" { } ''
        mkdir -p "$out/share/raspberrypi/boot"
        ln -s ${pkgs.unstable.raspberrypifw}/share/raspberrypi/boot/* "$out/share/raspberrypi/boot/"
        rm "$out"/share/raspberrypi/boot/{start4*.elf,fixup4*.dat}
        for dtb in "$out"/share/raspberrypi/boot/*.dtb; do
          case "$(basename "$dtb")" in
            bcm2710-rpi-3-b.dtb|bcm2710-rpi-3-b-plus.dtb) ;;
            *) rm "$dtb" ;;
          esac
        done
      '';

      uboot = {
        enable = true;
        package = pkgs.unstable.ubootRaspberryPiAarch64;
      };
    };
  };

  environment.systemPackages = [ pkgs.raspberrypi-utils ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
  };

  # Built with nix build .#nixosConfigurations.radiogaga.config.system.build.images.sd-card
  image.modules.sd-card =
    { lib, modulesPath, ... }:
    {
      # The installer profile's rescue tools, filesystems and ZFS serve no purpose on this card.
      disabledModules = [ "${modulesPath}/profiles/base.nix" ];
      # The deployed system boots without all-hardware's initrd modules and firmware.
      hardware.enableAllHardware = lib.mkForce false;
      sdImage.firmwareSize = 512;
    };

  nixpkgs.hostPlatform = "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Prefer compressed RAM swap before falling back to the SD card.
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];
}
