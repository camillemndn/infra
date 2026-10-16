_: {
  deployment.targetHost = "offspring.mndn.fr";

  networking = {
    firewall = {
      allowedUDPPorts = [ 51820 ];
    };

    wireguard.interfaces.wg0 = {
      ips = [ "10.100.46.1/24" ];
      allowedIPsAsRoutes = false;
      privateKeyFile = "/etc/wireguard/privatekey";
      listenPort = 51820;

      peers = [
        {
          # quilapayun
          publicKey = "sF4B+6Lw6wNqIb+uV3STbS5nX8x+jO1Udo9U471ciFY=";
          allowedIPs = [ "10.100.46.2/32" ];
        }
      ];
    };
  };
}
