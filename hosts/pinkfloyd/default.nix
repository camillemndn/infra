{ pkgs, ... }:

{
  hardware.sane.enable = true;
  # Remote desktop.
  networking.firewall.allowedTCPPorts = [ 3389 ];

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.autoLogin = {
      enable = true;
      user = "michel";
    };

    ipp-usb.enable = true;
    openssh.settings.PasswordAuthentication = true;
    printing.drivers = with pkgs; [ samsung-unified-linux-driver ];
  };

  system.stateVersion = "25.05";

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
      metronome
      qgis
    ];
  };
}
