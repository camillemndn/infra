{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "zeppelin";
    firewall.allowedTCPPorts = [ 2022 ];
    firewall.allowedUDPPorts = [ 51820 ];

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
          endpoint = "[2a01:e0a:5f9:9681:5880:c9ff:fe9f:3dfb]:51821";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  mailserver.enable = true;

  services = {
    buildbot-nix.master.enable = true;

    grafana.enable = true;

    jellyfin.enable = true;

    hammond = {
      enable = true;
      hostName = "car.kms";
    };

    jitsi-meet = {
      enable = true;
      hostName = "meet.mondon.xyz";
    };

    mattermost = {
      enable = true;
      siteUrl = "https://projects.mondon.xyz";
      listenAddress = "127.0.0.1:8065";
    };
    nginx.virtualHosts."projects.mondon.xyz" = {
      port = 8065;
      websockets = true;
    };

    nextcloud.enable = true;

    nginx = {
      enable = true;
      noDefault.enable = true;
      publicDomains = [
        "mondon.xyz"
        "saumon.network"
        "yali.es"
        "ceciliaflamenca.com"
        "camillemondon.com"
        "camillemondon.fr"
      ];
    };

    nginx.virtualHosts."yali.es".root = "/srv/sites/yali";
    nginx.virtualHosts."ceciliaflamenca.com".root = "/srv/sites/cecilia-flamenca";
    nginx.virtualHosts."camillemondon.com" = {
      root = "/srv/sites/camille-mondon";
      extraConfig = "error_page 404 /404.html;";
      locations."~ solution\.(html|pdf)".basicAuthFile = "/srv/sites/camillemondon_auth";
    };
    nginx.virtualHosts."camillemondon.fr".locations."/".return = "301 https://camillemondon.com$request_uri";
    nginx.virtualHosts."camille.mondon.xyz".locations."/".return = "301 https://camillemondon.com$request_uri";

    onlyoffice = {
      enable = true;
      hostname = "office.kms";
      port = 8001;
    };

    openssh.enable = true;

    photoprism.enable = true;

    tailscale.enable = true;

    tandoor-recipes = {
      enable = true;
      port = 8180;
    };
    nginx.virtualHosts."meals.mondon.xyz".port = 8180;

    vaultwarden.enable = true;

    webtrees = {
      enable = true;
      hostName = "family.mondon.xyz";
    };

    wordpress = {
      sites."wordpress.kms".package = pkgs.wordpress6_5;
      webserver = "nginx";
    };

    yarr.enable = true;
  };

  system.stateVersion = "21.11";
}
