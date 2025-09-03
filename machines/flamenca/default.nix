{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "flamenca";
    networkmanager.enable = true;
  };

  deployment = {
    targetHost = null;
    allowLocalDeployment = true;
  };

  hardware = {
    bluetooth.enable = true;
    sane.enable = true;
  };

  programs.firefox.enable = true;

  services = {
    xserver.enable = true;
    desktopManager.plasma6.enable = true;

    displayManager = {
      autoLogin = {
        enable = true;
        user = "cecilia";
      };
      sddm = {
        enable = true;
        autoLogin.relogin = true;
        wayland.enable = true;
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    pulseaudio.enable = false;

    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    openssh.enable = true;
    tailscale.enable = true;
  };

  security.rtkit.enable = true;

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
      libreoffice-qt6-fresh
      gimp-with-plugins
      tenacity
      mpv
      vlc
      inkscape
      signal-desktop
    ];
  };

  system.stateVersion = "24.05";
}
