{ config, lib, ... }:

let
  cfg = config.profiles.wireguard;
in
with lib;

{
  options.profiles.wireguard = {
    enable = mkEnableOption "Activate my Wireguard config";
  };

  config = mkIf cfg.enable {
    networking.wireguard.interfaces.wg0 = {
      ips = [ "10.100.45.3/24" ];
      allowedIPsAsRoutes = false;
      privateKeyFile = "/etc/wireguard/privatekey";
      listenPort = 51820;

      peers = [
        {
          # lisa
          publicKey = "oYsN1Qy+a7dwVOKapN5s5KJOmhSflLHZqh+GLMeNpHw=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "[2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb]:51821";
          persistentKeepalive = 25;
        }
      ];
    };

    networking.firewall.allowedUDPPorts = [ 51820 ];
  };
}
