let
  addresses = {
    ipv4.vpn = "100.100.45.5";
    ipv6.vpn = "fd7a:115c:a1e0::5";
  };
in
_: {
  networking = {
    inherit addresses;
  };
  deployment = {
    targetHost = addresses.ipv4.vpn;
  };
  services = {
  };
}
