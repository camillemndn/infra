{ config, pkgs, ... }:

{
  networking = {
    hostName = "icecube";
    hostId = "4ce8e212";
    networkmanager.enable = true;
  };

  services.xserver = {
    enable = true;
    layout = "fr";
    dpi = 230;
    displayManager.gdm.enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;

    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
      touchpad.accelSpeed = "0.3";
    };
  };

  programs.dconf.enable = true;
  hardware.video.hidpi.enable = true;
  environment.variables = {
    GDK_SCALE = "3";
    GDK_DPI_SCALE = "0.333";
    XCURSOR_SIZE = "64";
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Ubuntu" ]; })
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.logiops.enable = true;

  programs.mosh.enable = true;
  services.tailscale.enable = true;

  sops.age.keyFile = "/home/camille/.config/sops/age/keys.txt";

  system.stateVersion = "23.05";
}

