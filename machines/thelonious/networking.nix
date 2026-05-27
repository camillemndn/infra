{ lib, ... }:

{
  networking = {
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [ 53317 ]; # LocalSend
      allowedUDPPorts = [ 53317 ]; # LocalSend
    };
  };

  deployment = {
    allowLocalDeployment = true;
    targetHost = lib.infra.machines.thelonious.ipv4.vpn;
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };
}
