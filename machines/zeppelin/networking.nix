let
  meta = import ./meta.nix;
in
_: {
  networking = {
    firewall.allowedTCPPorts = [
      25565
    ];
    firewall.allowedUDPPorts = [ 51820 ];
    useDHCP = false;
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.45.3/24" ];
      allowedIPsAsRoutes = false;
      privateKeyFile = "/etc/wireguard/privatekey";
      listenPort = 51820;

      peers = [
        {
          # lisa
          publicKey = "oYsN1Qy+a7dwVOKapN5s5KJOmhSflLHZqh+GLMeNpHw=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "[2001:0bc8:3d24::45]:51821";
          persistentKeepalive = 25;
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
