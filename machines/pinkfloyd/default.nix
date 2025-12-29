{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  deployment = {
    targetHost = lib.infra.machines.pinkfloyd.ipv6.vpn;
    allowLocalDeployment = true;
  };

  networking = {
    hostName = "pinkfloyd";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 3389 ];
  };

  hardware.sane.enable = true;

  programs.firefox.enable = true;

  services = {
    desktopManager.plasma6.enable = true;

    displayManager = {
      sddm = {
        enable = true;
        autoLogin.relogin = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = "michel";
      };
    };

    ipp-usb.enable = true;

    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };

    printing = {
      enable = true;
      drivers = with pkgs; [ samsung-unified-linux-driver ];
    };

    tailscale.enable = true;
    xserver.enable = true;
  };

  users.users.michel = {
    description = "Michel";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    isNormalUser = true;

    packages = with pkgs; [
      freecad-qt6
      gimp
      inkscape-with-extensions
      kdePackages.filelight
      kdePackages.kate
      kdePackages.skanlite
      kdePackages.partitionmanager
      libreoffice-qt6-fresh
      metronome
      qgis
      thunderbird
    ];
  };

  system.stateVersion = "25.05";
}
