_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "radiogaga";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  deployment.buildOnTarget = false;

  profiles = {
    radiogaga.enable = true;
    spotify.enable = true;
  };

  services = {
    nginx.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "22.11";
}
