{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "flamenca";
  networking.networkmanager.enable = true;

  deployment = {
    targetHost = null;
    allowLocalDeployment = true;
  };

  hardware.bluetooth.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
    ];

  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    autoLogin.relogin = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  hardware.sane.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.cecilia = {
    isNormalUser = true;
    description = "Cecilia";
    extraGroups = [
      "networkmanager"
      "wheel"
      "lp"
      "scanner"
    ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kpat
      kdePackages.skanlite
      thunderbird
      google-chrome
      libreoffice-qt6-fresh
      gimp-with-plugins
      tenacity
      mpv
      vlc
      inkscape
      signal-desktop
    ];
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "cecilia";

  programs.firefox.enable = true;

  services.openssh.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "24.05";
}
