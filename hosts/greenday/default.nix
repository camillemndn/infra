{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ waypipe ];
  hardware.sane.enable = true;
  # Remote desktop.
  networking.firewall.allowedTCPPorts = [ 3389 ];

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

  users.users.georgette = {
    isNormalUser = true;
    description = "Georgette";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  system.stateVersion = "24.05";
}
