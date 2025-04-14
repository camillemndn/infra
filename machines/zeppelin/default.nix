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
          endpoint = "[2001:0bc8:3d24::45]:51821";
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

    jitsi-meet = {
      enable = true;
      hostName = "meet.mondon.xyz";
    };

    lubelogger.enable = true;

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
        "varanda.fr"
        "camillemondon.com"
        "camillemondon.fr"
      ];
    };

    nginx.virtualHosts."ceciliaflamenca.com".root = "/srv/sites/ceciliaflamenca.com/www";
    nginx.virtualHosts."www.varanda.fr".locations."/".return = "301 https://varanda.fr$request_uri";
    nginx.virtualHosts."yali.es".root = "/srv/sites/yali.es/www";

    nginx.virtualHosts."camillemondon.com" = {
      root = "/srv/sites/camillemondon.com/www";
      extraConfig = ''
        rewrite ^([^.]*[^/])$ $1/ permanent;
        error_page 404 /404.html;
      '';
      locations = {
        "/dda/".alias = "/srv/sites/dda/www/";
        "/projects/ot/".alias = "/srv/sites/optimal-transport/www/";
        "/projects/plnar/".alias = "/srv/sites/plnar/www/";
        "/projects/random-densities/".alias = "/srv/sites/thesis/www/";
        "/random-densities/".return = "301 https://$server_name/projects$request_uri";
        "/talks/codawork2024/".alias = "/srv/sites/thesis/www/materials/codawork2024/";
        "/talks/fosdem24-clevis/".alias = "/srv/sites/fosdem24-clevis/www/";
        "/talks/jds2024/".alias = "/srv/sites/thesis/www/materials/jds2024/";
        "/talks/fda/".alias = "/srv/sites/thesis/www/materials/fda/";
        "/teaching/hidimdaml".extraConfig = ''
          rewrite ^/teaching/hidimdaml/(.*)$ https://hidimdaml.camillemondon.com/$1 permanent;
        '';
        "/teaching/ics/".alias = "/srv/sites/thesis/www/materials/ics/";
      };
    };
    nginx.virtualHosts."hidimdaml.camillemondon.com" = {
      extraConfig = ''
        error_page 404 https://camillemondon.com/404.html;
      '';
      root = "/srv/sites/hidimdaml/www";
      locations."~ solution\\.(html|pdf)".basicAuthFile = "/srv/sites/camillemondon.com_auth";
    };
    nginx.virtualHosts."camillemondon.fr".locations."/".return =
      "301 https://camillemondon.com$request_uri";
    nginx.virtualHosts."camille.mondon.xyz".locations."/".return =
      "301 https://camillemondon.com$request_uri";
    nginx.virtualHosts."www.camillemondon.com".locations."/".return =
      "301 https://camillemondon.com$request_uri";

    collabora-online.enable = true;

    openssh.enable = true;

    plausible.enable = true;

    photoprism.enable = true;

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

    wordpress = {
      sites."varanda.fr" = {
        languages = [ pkgs.wordpressPackages.languages.fr_FR ];
        settings.WPLANG = "fr_FR";
      };
      webserver = "nginx";
    };

    yarr.enable = true;

    webhook.enable = true;
  };

  security.acme.certs."camillemondon.com".extraDomainNames = [ "www.camillemondon.com" ];
  security.acme.certs."varanda.fr".extraDomainNames = [ "www.varanda.fr" ];

  system.stateVersion = "21.11";
}
