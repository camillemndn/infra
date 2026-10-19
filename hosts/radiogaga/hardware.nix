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
    # Linux uses its matching mainline device trees; firmware DTBs serve U-Boot.
    loader.generic-extlinux-compatible.useGenerationDeviceTree = true;
  };

  hardware = {
    bluetooth.enable = true;

    # Let nixos-hardware manage config.txt, firmware, overlays and U-Boot.
    raspberry-pi.firmware = {
      enable = true;

      # Keep all Pi 3 variants and overlays, but omit Pi 4-only boot firmware
      # so the upstream installer's temporary copies fit the 30 MiB partition.
      package = pkgs.runCommand "raspberrypi3-firmware" { } ''
        mkdir -p "$out/share/raspberrypi/boot"
        ln -s ${pkgs.unstable.raspberrypifw}/share/raspberrypi/boot/* "$out/share/raspberrypi/boot/"
        rm "$out"/share/raspberrypi/boot/{start4*.elf,fixup4*.dat}
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

  nixpkgs.hostPlatform = "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  # Prefer compressed RAM swap before falling back to the SD card.
  zramSwap.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];
}
