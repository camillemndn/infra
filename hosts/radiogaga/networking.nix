let
  addresses = {
    ipv4.local = "192.168.1.50";
  };
in
_: {
  networking = {
    inherit addresses;
    networkmanager.enable = true;
  };

  deployment = {
    targetHost = addresses.ipv4.local;
    buildOnTarget = false;
  };

  services.openssh.enable = true;
}
