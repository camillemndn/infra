_:

{
  networking = {
    hostName = "nickelback";
    hostId = "c5cdb5c5";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  profiles.manu.enable = true;

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "21.11";
}

