{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  deployment = {
    buildOnTarget = false;
    targetPort = 60;
    targetHost = lib.infra.machines.greenday.ipv4.public;
  };

  networking.hostName = "greenday";
  networking.networkmanager.enable = true;

  users.mutableUsers = true;
  users.users.georgette = {
    isNormalUser = true;
    description = "Georgette";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
      inkscape
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
      };
      autoLogin = {
        enable = true;
        user = "georgette";
      };
    };

    openssh.enable = true;
    tailscale.enable = true;
    x2goserver.enable = true;
    printing.enable = true;
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [ ];

  system.stateVersion = "24.05";
}
