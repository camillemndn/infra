{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  users.users.georgette = {
    isNormalUser = true;
    description = "Georgette";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.filelight
      kdePackages.skanlite
      thunderbird
      inkscape-with-extensions
      kitty
      gimp
      libreoffice-qt-fresh
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
    printing = {
      enable = true;
      drivers = with pkgs; [ samsung-unified-linux-driver ];
    };
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [ waypipe ];

  system.stateVersion = "24.05";
}
