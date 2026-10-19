{
  networking = {
    firewall.allowedUDPPorts = [ 51820 ];

    wireguard.interfaces.wg0 = {
      allowedIPsAsRoutes = false;
      ips = [ "10.100.46.1/24" ];
      listenPort = 51820;

      peers = [
        {
          allowedIPs = [ "10.100.46.2/32" ];
          # quilapayun
          publicKey = "sF4B+6Lw6wNqIb+uV3STbS5nX8x+jO1Udo9U471ciFY=";
        }
      ];

      privateKeyFile = "/etc/wireguard/privatekey";
    };
  };
}
