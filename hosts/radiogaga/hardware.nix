{ lib, pkgs, ... }:

with lib;

let
  configTxt = pkgs.writeText "config.txt" ''
    [pi3]
    kernel=u-boot-rpi3.bin

    [all]
    # Boot in 64-bit mode.
    arm_64bit=1

    # U-Boot needs this to work, regardless of whether UART is actually used or not.
    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
    # a requirement in the future.
    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    avoid_warnings=1
  '';

  raspberrypi-update-3b = pkgs.writeShellScriptBin "rpi-update-3b" ''
    set -euo pipefail
    export PATH=${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.util-linux
      ]
    }

    firmware_dir=/boot/firmware
    firmware_device=$(readlink -e /dev/disk/by-label/FIRMWARE)
    if ! mountpoint -q "$firmware_dir"; then
      mkdir -p "$firmware_dir"
      mount -t vfat "$firmware_device" "$firmware_dir"
    fi

    # Never write boot files into the root filesystem or an unrelated mount.
    if ! findmnt -rn -M "$firmware_dir" -S "$firmware_device" -t vfat >/dev/null; then
      echo "FIRMWARE is not mounted at $firmware_dir; refusing to update" >&2
      exit 1
    fi

    staging_dir=$(mktemp -d "$firmware_dir/.rpi-update-3b.XXXXXX")
    trap 'rm -rf -- "$staging_dir"' EXIT
    cp ${pkgs.unstable.raspberrypifw}/share/raspberrypi/boot/{bootcode.bin,fixup*.dat,start*.elf} "$staging_dir/"
    cp ${configTxt} "$staging_dir/config.txt"
    cp ${pkgs.unstable.ubootRaspberryPi3_64bit}/u-boot.bin "$staging_dir/u-boot-rpi3.bin"
    sync -f "$firmware_dir"

    for source in "$staging_dir"/*; do
      destination="$firmware_dir/$(basename "$source")"
      if ! cmp -s "$source" "$destination"; then
        mv -f -- "$source" "$destination"
      fi
    done
    sync -f "$firmware_dir"
    # Leave the declaratively managed filesystem mounted.
  '';
in

{
  boot = {
    loader = {
      efi.canTouchEfiVariables = false;
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    kernelModules = [ "snd-aloop" ];

    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
    ];
  };

  environment.systemPackages = [
    pkgs.raspberrypi-update
    pkgs.raspberrypi-utils
    raspberrypi-update-3b
  ];

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

  networking = {
    useDHCP = mkDefault false;

    interfaces = {
      eth0.useDHCP = mkDefault true;
      wlan0.useDHCP = mkDefault true;
    };
  };

  nixpkgs.hostPlatform = "aarch64-linux";
  powerManagement.cpuFreqGovernor = mkDefault "ondemand";

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  system.activationScripts.raspberrypi-update = "${raspberrypi-update-3b}/bin/rpi-update-3b";
}
