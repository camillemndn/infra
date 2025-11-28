{ lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "zeppelin";
    firewall.allowedTCPPorts = [
      2022
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
    grafana.enable = true;
    jellyfin.enable = true;
    jitsi-meet.enable = true;
    mattermost.enable = true;
    minecraft-server.enable = true;
    nextcloud.enable = true;

    nginx = {
      enable = true;
      noDefault.enable = true;
      publicDomains = [
        "camillemondon.com"
        "camillemondon.fr"
        "ceciliaflamenca.com"
        "mondon.xyz"
        "saumon.network"
        "varanda.fr"
        "yali.es"
      ];
    };

    nginx.virtualHosts."camillemondon.com" = {
      root = "/srv/sites/camillemondon.com/www";
      extraConfig = ''
        rewrite ^([^.]*[^/])$ $1/ permanent;
        error_page 404 /404.html;
      '';
      locations = {
        "/assets/".extraConfig = ''
          expires 1y;
          add_header Cache-Control "public";
        '';
        "/dda/".alias = "/srv/sites/dda/www/";
        "/projects/ot/".alias = "/srv/sites/optimal-transport/www/";
        "/projects/icscoda/".alias = "/srv/sites/icscoda/www/";
        "/projects/plnar/".alias = "/srv/sites/plnar/www/";
        "/projects/random-densities/".alias = "/srv/sites/thesis/www/";
        "/publications/2025/icscomplex/".alias = "/srv/sites/icscomplex/www/";
        "/publications/2025/danova/".alias = "/srv/sites/danova/www/";
        "/publications/2026/icsfobi/".alias = "/srv/sites/icsfobi/www/";
        "/random-densities/".return = "301 https://$server_name/projects$request_uri";
        "/talks/fosdem24-clevis/".alias = "/srv/sites/fosdem24-clevis/www/";
        "/talks/fda/".alias = "/srv/sites/thesis/www/materials/fda/";
        "/talks/jds2024/".alias = "/srv/sites/thesis/www/materials/jds2024/";
        "/talks/codawork2024/".alias = "/srv/sites/thesis/www/materials/codawork2024/";
        "/talks/helsinki2025/".alias = "/srv/sites/thesis/www/materials/helsinki2025/";
        "/talks/tse2025/".alias = "/srv/sites/thesis/www/materials/tse2025/";
        "/teaching/hidimdaml".extraConfig = ''
          rewrite ^/teaching/hidimdaml/(.*)$ https://hidimdaml.camillemondon.com/$1 permanent;
        '';
        "/teaching/ics/".alias = "/srv/sites/thesis/www/materials/ics/";
      };
    };
    nginx.virtualHosts."www.camillemondon.com".locations."/".return =
      "301 https://camillemondon.com$request_uri";

    nginx.virtualHosts."camillemondon.fr".locations."/".return =
      "301 https://camillemondon.com$request_uri";

    nginx.virtualHosts."camille.mondon.xyz".locations."/".return =
      "301 https://camillemondon.com$request_uri";

    nginx.virtualHosts."ceciliaflamenca.com" = {
      root = "/srv/sites/ceciliaflamenca.com/www";
      locations."/images/".extraConfig = ''
        expires 1y;
        add_header cache-control "public";
      '';
    };

    nginx.virtualHosts."hidimdaml.camillemondon.com" = {
      extraConfig = ''
        error_page 404 https://camillemondon.com/404.html;
      '';
      root = "/srv/sites/hidimdaml/www";
      locations."~ solution\\.(html|pdf)".basicAuthFile = "/srv/sites/camillemondon.com_auth";
    };

    nginx.virtualHosts."varanda.fr" = {
      root = "/srv/sites/varanda.fr/www";
      locations."/static/".extraConfig = ''
        expires 1y;
        add_header Cache-Control "public";
      '';
      extraConfig = ''
        error_page 404 /404/;
      '';
    };
    nginx.virtualHosts."www.varanda.fr".locations."/".return = "301 https://varanda.fr$request_uri";

    nginx.virtualHosts."yali.es" = {
      root = "/srv/sites/yali.es/www";
      locations."/images/".extraConfig = ''
        expires 1y;
        add_header cache-control "public";
      '';
    };

    openssh.enable = true;
    photoprism.enable = true;
    plausible.enable = true;
    tailscale.enable = true;

    tandoor-recipes = {
      enable = true;
      port = 8180;
      extraConfig.GUNICORN_MEDIA = "1";
    };
    nginx.virtualHosts."meals.mondon.xyz".port = 8180;

    vaultwarden.enable = true;

    webtrees = {
      enable = true;
      hostName = "family.mondon.xyz";
    };

    yarr.enable = true;
    webhook.enable = true;
  };

  security.acme.certs."camillemondon.com".extraDomainNames = [ "www.camillemondon.com" ];
  security.acme.certs."varanda.fr".extraDomainNames = [ "www.varanda.fr" ];

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
