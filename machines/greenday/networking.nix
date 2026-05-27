let
  meta = import ./meta.nix;
in
_: {
  deployment = {
    targetHost = meta.ipv6.vpn;
    allowLocalDeployment = true;
  };

  networking = {
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 3389 ];
  };

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };

    tailscale.enable = true;
  };
}
