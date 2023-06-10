{ lib, pkgs, ... }:

with lib;

{
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    extraModprobeConfig = ''
      # options snd_bcm2835 enable_headphones=1 enable_compat_alsa=1
      options cfg80211 ieee80211_regdom="FR"
    '';
  };

  hardware = {
    enableRedistributableFirmware = mkDefault true;
    firmware = with pkgs; [ raspberrypiWirelessFirmware wireless-regdb ];
  };

  environment.systemPackages = [ pkgs.libraspberrypi ];

  powerManagement.cpuFreqGovernor = mkDefault "ondemand";

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  swapDevices = [ ];

  networking.useDHCP = mkDefault false;
  networking.interfaces.eth0.useDHCP = mkDefault true;
  networking.interfaces.wlan0.useDHCP = mkDefault true;
}
