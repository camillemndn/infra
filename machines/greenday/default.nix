{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  deployment = {
    targetHost = lib.infra.machines.greenday.ipv4.public;
    targetPort = 60;
    buildOnTarget = false;
    allowLocalDeployment = true;
  };

  networking.hostName = "greenday";
  networking.networkmanager.enable = true;

  users.users.georgette = {
    isNormalUser = true;
    description = "Georgette";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.krfb
      kdePackages.partitionmanager
      kdePackages.skanlite
      thunderbird
      inkscape-with-extensions
      gimp
      libreoffice-qt6-fresh
    ];
  };

  services = {
    xserver.enable = true;
    desktopManager.plasma6.enable = true;

    displayManager = {
      sddm = {
        enable = true;
        autoLogin.relogin = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = "georgette";
      };
    };

    ipp-usb.enable = true;

    xrdp = {
      enable = true;
      defaultWindowManager = "startplasma-wayland";
      openFirewall = true;
    };

    openssh.enable = true;
    openssh.settings.PasswordAuthentication = true;
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        samsung-unified-linux-driver
      ];
    };
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [ waypipe ];

  system.stateVersion = "24.05";
}
