{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Mullvad namespace: only the tunnel and a veth to the host, so nothing leaks when the tunnel is down.
  vpnServices = [
    "deluged"
    "delugeweb"
    "flood"
    "slskd"
  ];

  # Relayed to the host loopback for nginx and the *arr clients.
  vpnPorts = [
    3022 # flood
    5030 # slskd
    8112 # deluge-web
  ];

  vpnAddress = "10.200.0.2";

  vpnRules = pkgs.writeText "netns-vpn.nft" ''
    table inet filter {
      chain input {
        type filter hook input priority 0; policy drop;
        iif "lo" accept
        ct state established,related accept
        iifname "vpn0" tcp dport { ${lib.concatMapStringsSep ", " toString vpnPorts} } accept
      }
    }
  '';

  proxyName = port: "netns-vpn-proxy-${toString port}";
in
{
  # Mullvad's resolver, reachable only through the tunnel.
  environment.etc."netns/vpn/resolv.conf".text = ''
    nameserver 10.64.0.1
  '';

  networking = {
    firewall.allowedUDPPorts = [ 51820 ];

    wireguard.interfaces.wg0 = {
      # Socket on the host, interface and routes in the namespace.
      interfaceNamespace = "vpn";

      # Device: Pretty Ox
      ips = [
        "10.66.154.125/32"
        "fc00:bbbb:bbbb:bb01::3:9a7c/128"
      ];

      listenPort = 51820;

      peers = [
        {
          allowedIPs = [
            "0.0.0.0/0"
            "::0/0"
          ];

          endpoint = "[2a03:1b20:9:f011::a01f]:51820";
          publicKey = "ov323GyDOEHLT0sNRUUPYiE3BkvFDjpmi1a4fzv49hE=";
        }
      ];

      privateKeyFile = "/etc/wireguard/privatekey";
    };
  };

  services = {
    # Inside the namespace, localhost is not reachable from the relay.
    flood.host = "0.0.0.0";
  };

  systemd = {
    network.networks = {
      # Before 10-wan, whose Type=ether would claim the veth.
      "05-veth-vpn" = {
        address = [ "10.200.0.1/30" ];
        linkConfig.RequiredForOnline = "no";
        matchConfig.Name = "veth-vpn";
        networkConfig.LinkLocalAddressing = "no";
      };
    };

    services = lib.mkMerge [
      {
        netns-vpn = {
          after = [ "network-pre.target" ];
          before = [ "network.target" ];
          description = "Network namespace for services confined to the Mullvad tunnel";

          path = with pkgs; [
            iproute2
            nftables
          ];

          postStop = ''
            ip netns del vpn || true
          '';

          # A namespace still held open outlives `ip netns del` and keeps its veth
          # peer alive on the host side.
          script = ''
            ip netns del vpn 2>/dev/null || true
            ip link del veth-vpn 2>/dev/null || true
            ip netns add vpn
            ip -n vpn link set lo up
            ip link add veth-vpn type veth peer name vpn0 netns vpn
            ip link set veth-vpn up
            ip -n vpn address add ${vpnAddress}/30 dev vpn0
            ip -n vpn link set vpn0 up
            ip netns exec vpn nft -f ${vpnRules}
          '';

          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
          };
        };

        wireguard-wg0 = {
          after = [ "netns-vpn.service" ];
          partOf = [ "netns-vpn.service" ];
          requires = [ "netns-vpn.service" ];
        };
      }
      (lib.genAttrs vpnServices (_: {
        after = [ "wireguard-wg0.service" ];
        partOf = [ "netns-vpn.service" ];
        requires = [ "wireguard-wg0.service" ];

        serviceConfig = {
          BindReadOnlyPaths = [ "/etc/netns/vpn/resolv.conf:/etc/resolv.conf" ];
          # nscd answers from the host namespace, outside the tunnel.
          InaccessiblePaths = [ "-/run/nscd" ];
          NetworkNamespacePath = "/run/netns/vpn";
        };
      }))
      (lib.listToAttrs (
        map (
          port:
          lib.nameValuePair (proxyName port) {
            after = [ "${proxyName port}.socket" ];
            description = "Relay 127.0.0.1:${toString port} into the VPN namespace";
            requires = [ "${proxyName port}.socket" ];

            serviceConfig = {
              DynamicUser = true;
              ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd ${vpnAddress}:${toString port}";
            };
          }
        ) vpnPorts
      ))
      {
        # Without nscd glibc cannot resolve flood's dynamic user, and Node reads $HOME first.
        flood.environment.HOME = "/var/lib/flood";
      }
    ];

    sockets = lib.listToAttrs (
      map (
        port:
        lib.nameValuePair (proxyName port) {
          listenStreams = [ "127.0.0.1:${toString port}" ];
          wantedBy = [ "sockets.target" ];
        }
      ) vpnPorts
    );
  };
}
