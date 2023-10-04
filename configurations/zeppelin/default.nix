_:

{
  networking = {
    hostName = "zeppelin";
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    hammond = { enable = true; hostName = "car.kms"; };
    mattermost = { enable = true; siteUrl = "https://projects.mondon.xyz"; };
    nginx.virtualHosts."projects.mondon.xyz".port = 8065;
    nginx.noDefault.enable = true;
    nginx.publicDomains = [ "mondon.xyz" "saumon.network" "yali.es" "ceciliaflamenca.com" ];
    nginx.virtualHosts."yali.es".root = "/srv/sites/yali";
    nginx.virtualHosts."ceciliaflamenca.com".root = "/srv/sites/cecilia-flamenca";
    openssh.enable = true;
    tailscale.enable = true;
    webtrees = { enable = true; hostName = "family.mondon.xyz"; };
  };

  profiles = {
    cloud.enable = true;
    feeds.enable = true;
    graphs.enable = true;
    meals.enable = true;
    mail-server.enable = true;
    media-server.enable = true;
    meet = { enable = true; hostName = "meet.mondon.xyz"; };
    passwords.enable = true;
    photos.enable = true;
  };

  system.stateVersion = "21.11";
}

