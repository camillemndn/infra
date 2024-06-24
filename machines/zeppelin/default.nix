{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "zeppelin";
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    hammond = {
      enable = true;
      hostName = "car.kms";
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
    nginx.enable = true;
    nginx.noDefault.enable = true;
    nginx.publicDomains = [
      "mondon.xyz"
      "saumon.network"
      "yali.es"
      "ceciliaflamenca.com"
      "camillemondon.com"
      "camillemondon.fr"
    ];
    nginx.virtualHosts."yali.es".root = "/srv/sites/yali";
    nginx.virtualHosts."ceciliaflamenca.com".root = "/srv/sites/cecilia-flamenca";
    nginx.virtualHosts."camillemondon.com" = {
      root = "/srv/sites/camille-mondon";
      extraConfig = "error_page 404 /404.html;";
      locations."~ solution\.(html|pdf)".basicAuthFile = "/srv/sites/camillemondon_auth";
    };
    nginx.virtualHosts."camillemondon.fr".locations."/".return = "301 https://camillemondon.com$request_uri";
    nginx.virtualHosts."camille.mondon.xyz".locations."/".return = "301 https://camillemondon.com$request_uri";
    openssh.enable = true;
    onlyoffice = {
      enable = true;
      hostname = "office.kms";
      port = 8001;
    };
    tailscale.enable = true;
    webtrees = {
      enable = true;
      hostName = "family.mondon.xyz";
    };
    wordpress = {
      sites."wordpress.kms".package = pkgs.wordpress6_4;
      webserver = "nginx";
    };
  };

  profiles = {
    cloud.enable = true;
    feeds.enable = true;
    graphs.enable = true;
    meals.enable = true;
    mail-server.enable = true;
    media-server.enable = true;
    meet = {
      enable = true;
      hostName = "meet.mondon.xyz";
    };
    passwords.enable = true;
    photos.enable = true;
    wireguard.enable = true;
  };

  system.stateVersion = "21.11";
}
