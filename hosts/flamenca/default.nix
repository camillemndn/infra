{ pkgs, ... }:

{
  hardware.sane.enable = true;

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.autoLogin = {
      enable = true;
      user = "cecilia";
    };
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
      kdePackages.kpat
      audacity
      vlc
      unstable.signal-desktop
    ];
  };

  system.stateVersion = "24.05";
}
