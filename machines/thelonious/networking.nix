let
  meta = import ./meta.nix;
in
_: {
  networking = {
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [ 53317 ]; # LocalSend
      allowedUDPPorts = [ 53317 ]; # LocalSend
    };
  };

  deployment = {
    allowLocalDeployment = true;
    targetHost = meta.ipv4.vpn;
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };
}
