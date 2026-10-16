let
  addresses = {
    ipv4.vpn = "100.100.45.3";
    ipv6.vpn = "fd7a:115c:a1e0::3";
  };
in
_: {
  networking = {
    inherit addresses;
    firewall.allowedTCPPorts = [ 3389 ];
  };

  deployment = {
    targetHost = addresses.ipv6.vpn;
  };

  services = {
    openssh.settings.PasswordAuthentication = true;
  };
}
