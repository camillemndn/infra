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
    networking.wg-quick.interfaces = {
      wg1 = {
        privateKeyFile = "/srv/keys/wireguard";
        address = [ "192.168.27.65/32" ];
        # dns = [ "212.27.38.253" ];
        mtu = 1420;

        #postUp = ''
        #  ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.27.64/27 -o enp0s25 -j MASQUERADE
        #'';

        # This undoes the above command
        #postDown = ''
        #  ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.27.64/27 -o enp0s25 -j MASQUERADE
        #'';
        peers = [
          {
            publicKey = "U7k8anMKzmiO98Yzsrc6f9uJBUqJRkM0JzjuPDdKsAo=";
            allowedIPs = [ "192.168.27.64/27" ];
            endpoint = "82.66.152.179:51705";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
