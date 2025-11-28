_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "offspring";

    firewall = {
      allowedTCPPorts = [ 2022 ];
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

  deployment.targetHost = "offspring.mondon.xyz";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICu2PXuhmCpgkN3b0jWQIbNpYBDlzhGbeSpbK+k4nbRO camille@offspring"
  ];

  services = {
    openssh.enable = true;

    nginx = {
      enable = true;
      noDefault.enable = true;
      publicDomains = [
        "mondon.xyz"
        "saumon.network"
      ];
      virtualHosts."lists.saumon.network".locations."/".proxyPass = "http://10.100.46.2";
    };

    uptime-kuma.enable = true;
  };

  system.stateVersion = "23.05";
}
