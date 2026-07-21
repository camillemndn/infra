let
  meta = import ./meta.nix;
in
_: {
  deployment = {
    targetHost = "zeppelin.kms";
    allowLocalDeployment = true;
  };

  networking = {
    firewall.allowedUDPPorts = [ 51820 ];
    useDHCP = false;
    wireguard.interfaces.wg0 = {
      # Device: Pretty Ox
      ips = [
        "10.66.154.125/32"
        "fc00:bbbb:bbbb:bb01::3:9a7c/128"
      ];
      allowedIPsAsRoutes = false;
      privateKeyFile = "/etc/wireguard/privatekey";
      listenPort = 51820;
      peers = [
        {
          publicKey = "ov323GyDOEHLT0sNRUUPYiE3BkvFDjpmi1a4fzv49hE=";
          allowedIPs = [
            "0.0.0.0/0"
            "::0/0"
          ];
          endpoint = "[2a03:1b20:9:f011::a01f]:51820";
        }
      ];
    };
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Type = "ether";
      address = [
        "${meta.ipv4.local}/21"
        "${meta.ipv6.public}/64"
      ];
      routes = [ { Gateway = "192.168.0.1"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
