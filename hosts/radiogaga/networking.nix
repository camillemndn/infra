let
  addresses = {
    ipv4.local = "192.168.1.50";
  };
in
_: {
  networking = {
    inherit addresses;
  };

  deployment = {
    targetHost = addresses.ipv4.local;
    buildOnTarget = false;
    allowLocalDeployment = false;
  };

  services.tailscale.enable = false;
}
