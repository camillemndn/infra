let
  meta = import ./meta.nix;
in
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Services confined to the Mullvad tunnel join this namespace. Its only
  # routes are the tunnel and a veth link to the host, so traffic cannot
  # leave by any other path, even when the tunnel is down.
  vpnServices = [
    "deluged"
    "delugeweb"
    "flood"
    "slskd"
  ];

  # Web ports relayed from the host loopback, so nginx and the *arr download
  # clients keep reaching them on 127.0.0.1.
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
      # The UDP socket stays on the host; the interface and its routes live
      # in the namespace.
      interfaceNamespace = "vpn";
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

  # Mullvad's resolver, reachable only through the tunnel.
  environment.etc."netns/vpn/resolv.conf".text = ''
    nameserver 10.64.0.1
  '';

  services = {
    # Inside the namespace, localhost is not reachable from the relay.
    flood.host = "0.0.0.0";
    openssh.enable = true;
    tailscale.enable = true;
  };

  systemd.services = lib.mkMerge [
    {
      netns-vpn = {
        description = "Network namespace for services confined to the Mullvad tunnel";
        after = [ "network-pre.target" ];
        before = [ "network.target" ];
        path = with pkgs; [
          iproute2
          nftables
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ip netns del vpn 2>/dev/null || true
          ip netns add vpn
          ip -n vpn link set lo up
          ip link add veth-vpn type veth peer name vpn0 netns vpn
          ip link set veth-vpn up
          ip -n vpn address add ${vpnAddress}/30 dev vpn0
          ip -n vpn link set vpn0 up
          ip netns exec vpn nft -f ${vpnRules}
        '';
        postStop = ''
          ip netns del vpn || true
        '';
      };

      wireguard-wg0 = {
        requires = [ "netns-vpn.service" ];
        after = [ "netns-vpn.service" ];
        partOf = [ "netns-vpn.service" ];
      };
    }
    (lib.genAttrs vpnServices (_: {
      requires = [ "wireguard-wg0.service" ];
      after = [ "wireguard-wg0.service" ];
      partOf = [ "netns-vpn.service" ];
      serviceConfig = {
        NetworkNamespacePath = "/run/netns/vpn";
        BindReadOnlyPaths = [ "/etc/netns/vpn/resolv.conf:/etc/resolv.conf" ];
        # nscd answers from the host namespace, outside the tunnel.
        InaccessiblePaths = [ "-/run/nscd" ];
      };
    }))
    (lib.listToAttrs (
      map (
        port:
        lib.nameValuePair (proxyName port) {
          description = "Relay 127.0.0.1:${toString port} into the VPN namespace";
          requires = [ "${proxyName port}.socket" ];
          after = [ "${proxyName port}.socket" ];
          serviceConfig = {
            ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd ${vpnAddress}:${toString port}";
            DynamicUser = true;
          };
        }
      ) vpnPorts
    ))
    {
      # Without nscd, glibc cannot resolve flood's dynamic user; Node reads
      # $HOME before asking glibc for the home directory.
      flood.environment.HOME = "/var/lib/flood";
    }
  ];

  systemd.sockets = lib.listToAttrs (
    map (
      port:
      lib.nameValuePair (proxyName port) {
        wantedBy = [ "sockets.target" ];
        listenStreams = [ "127.0.0.1:${toString port}" ];
      }
    ) vpnPorts
  );

  systemd.network = {
    enable = true;
    # Sorts before 10-wan, whose Type=ether match would otherwise claim the veth.
    networks."05-veth-vpn" = {
      matchConfig.Name = "veth-vpn";
      address = [ "10.200.0.1/30" ];
      networkConfig.LinkLocalAddressing = "no";
      linkConfig.RequiredForOnline = "no";
    };
    networks."10-wan" = {
      matchConfig.Type = "ether";
      address = [ "${meta.ipv4.local}/21" ];
      routes = [ { Gateway = "192.168.0.1"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
