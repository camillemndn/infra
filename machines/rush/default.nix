_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "rush";
    hostId = "b8ed114c";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    openssh.enable = true;

    snapclient = {
      enable = true;
      serverHost = "radiogaga.local";
    };

    tailscale.enable = true;
  };

  system.stateVersion = "22.11";
}
