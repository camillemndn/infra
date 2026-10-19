{ pkgs, ... }:

{
  hardware.sane.enable = true;
  # Remote desktop.
  networking.firewall.allowedTCPPorts = [ 3389 ];

  users.users.georgette = {
    isNormalUser = true;
    description = "Georgette";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    packages = with pkgs; [
      inkscape-with-extensions
      kitty
      gimp
    ];
  };

  services = {
    desktopManager.plasma6.enable = true;
    openssh.settings.PasswordAuthentication = true;

    displayManager.autoLogin = {
      enable = true;
      user = "georgette";
    };

    ipp-usb.enable = true;
    printing.drivers = with pkgs; [ samsung-unified-linux-driver ];
  };

  environment.systemPackages = with pkgs; [ waypipe ];
  system.stateVersion = "24.05";
}
