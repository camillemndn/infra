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

  system.stateVersion = "24.05";

  users.users.cecilia = {
    description = "Cecilia";

    extraGroups = [
      "networkmanager"
      "wheel"
      "lp"
      "scanner"
    ];

    isNormalUser = true;

    packages = with pkgs; [
      kdePackages.kpat
      gimp-with-plugins
      audacity
      mpv
      vlc
      inkscape
      unstable.signal-desktop
    ];
  };
}
