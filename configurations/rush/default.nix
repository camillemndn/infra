{ config, ... }:

{
  networking = {
    hostName = "rush";
    hostId = "b8ed114c";
    wireless.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "22.11";
}

