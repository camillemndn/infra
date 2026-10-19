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

    staging_dir=
    trap 'if [[ -n "$staging_dir" ]]; then rm -rf -- "$staging_dir"; fi' EXIT

    stage_if_changed() {
      local source=$1 name=$2
      if cmp -s "$source" "$firmware_dir/$name"; then
        return
      fi
      if [[ -z "$staging_dir" ]]; then
        staging_dir=$(mktemp -d "$firmware_dir/.rpi-update-3b.XXXXXX")
      fi
      cp -- "$source" "$staging_dir/$name"
    }

    for source in ${pkgs.unstable.raspberrypifw}/share/raspberrypi/boot/{bootcode.bin,fixup*.dat,start*.elf}; do
      stage_if_changed "$source" "$(basename "$source")"
    done
    stage_if_changed ${configTxt} config.txt
    stage_if_changed ${pkgs.unstable.ubootRaspberryPi3_64bit}/u-boot.bin u-boot-rpi3.bin

    # An unchanged activation only reads the installed files.
    if [[ -z "$staging_dir" ]]; then
      exit 0
    fi

    # Stage all changes successfully before replacing any installed file.
    sync -f "$firmware_dir"
    for source in "$staging_dir"/*; do
      mv -f -- "$source" "$firmware_dir/$(basename "$source")"
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

    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
    ];
  };

  environment.systemPackages = [
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
    # NetworkManager owns DHCP for both Ethernet and Wi-Fi.
    networkmanager.enable = true;
    dhcpcd.enable = false;
  };

  nixpkgs.hostPlatform = "aarch64-linux";
  powerManagement.cpuFreqGovernor = mkDefault "ondemand";
  hardware.bluetooth.enable = true;
  # Prefer compressed RAM swap before falling back to the SD card.
  zramSwap.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  system.activationScripts.raspberrypi-update = "${raspberrypi-update-3b}/bin/rpi-update-3b";
}
