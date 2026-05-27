{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

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
    printing = {
      enable = true;
      drivers = with pkgs; [ samsung-unified-linux-driver ];
    };
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
      freecad
      gimp
      inkscape-with-extensions
      kdePackages.filelight
      kdePackages.kate
      kdePackages.skanlite
      libreoffice-qt-fresh
      metronome
      qgis
      thunderbird
    ];
  };

  system.stateVersion = "25.05";
}
