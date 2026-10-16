let
  addresses = {
    ipv4.vpn = "100.100.45.5";
    ipv6.vpn = "fd7a:115c:a1e0::5";
  };
in
_: {
  networking = {
    inherit addresses;
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [ 53317 ]; # LocalSend
      allowedUDPPorts = [ 53317 ]; # LocalSend
    };
  };

  deployment = {
    allowLocalDeployment = true;
    targetHost = addresses.ipv4.vpn;
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };
}
