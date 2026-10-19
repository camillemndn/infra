{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ waypipe ];
  hardware.sane.enable = true;
  # Remote desktop.
  networking.firewall.allowedTCPPorts = [ 3389 ];

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.autoLogin = {
      enable = true;
      user = "georgette";
    };

    ipp-usb.enable = true;
    openssh.settings.PasswordAuthentication = true;
    printing.drivers = with pkgs; [ samsung-unified-linux-driver ];
  };

  system.stateVersion = "24.05";

  users.users.georgette = {
    description = "Georgette";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    isNormalUser = true;

    packages = with pkgs; [
      inkscape-with-extensions
      kitty
      gimp
    ];
  };
}
