let
  addresses = {
    ipv4.vpn = "100.100.45.42";
    ipv6.vpn = "fd7a:115c:a1e0::2a";
  };
in
_: {
  networking = {
    inherit addresses;
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 3389 ];
  };

  deployment = {
    targetHost = addresses.ipv6.vpn;
    allowLocalDeployment = true;
  };

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };

    tailscale.enable = true;
  };
}
