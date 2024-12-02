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
    mount /dev/disk/by-label/FIRMWARE
    (cd ${pkgs.unstable.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf /mnt)

    # Add the config
    cp ${configTxt} /mnt/config.txt

    # Add pi3 specific files
    cp ${pkgs.unstable.ubootRaspberryPi3_64bit}/u-boot.bin /mnt/u-boot-rpi3.bin
    umount /dev/disk/by-label/FIRMWARE
  '';
in

{
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    kernelModules = [ "snd-aloop" ];
    kernelPackages = pkgs.unstable.linuxPackages_rpi3;
    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
    ];
  };

  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  environment.systemPackages = [
    pkgs.raspberrypi-update
    pkgs.raspberrypi-utils
    raspberrypi-update-3b
  ];

  system.activationScripts.raspberrypi-update = "${raspberrypi-update-3b}/bin/rpi-update-3b";

  hardware.enableRedistributableFirmware = mkDefault true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    systemWide = true;
  };

  powerManagement.cpuFreqGovernor = mkDefault "ondemand";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  networking.useDHCP = mkDefault false;
  networking.interfaces.eth0.useDHCP = mkDefault true;
  networking.interfaces.wlan0.useDHCP = mkDefault true;
}
