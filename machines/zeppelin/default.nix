{ lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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

  programs.nixvim.enable = true;

  services = {
    buildbot-nix.master.enable = true;
    collabora-online.enable = true;
    davmail.enable = true;
    firefly-iii.enable = true;
    immich.enable = true;
    jellyfin.enable = true;
    mattermost.enable = true;
    minecraft-server.enable = true;
    nextcloud.enable = true;
    nginx = {
      enable = true;
      noDefault.enable = true;
      websites = {
        "camillemondon.com".enable = true;
        "ceciliaflamenca.com".enable = true;
        "varanda.fr".enable = true;
        "yali.es".enable = true;
      };
    };
    openssh.enable = true;
    photoprism.enable = true;
    plausible.enable = true;
    tailscale.enable = true;
    tandoor-recipes.enable = true;
    vaultwarden.enable = true;
    webtrees = {
      enable = true;
      hostName = "family.mndn.fr";
    };
    webhook.enable = true;
  };

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Type = "ether";
      address = [
        "${lib.infra.machines.zeppelin.ipv4.local}/21"
        "${lib.infra.machines.zeppelin.ipv6.public}/64"
      ];
      routes = [ { Gateway = "192.168.0.1"; } ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  system.stateVersion = "21.11";
}
