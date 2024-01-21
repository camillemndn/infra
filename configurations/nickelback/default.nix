_:

{
  networking = {
    hostName = "nickelback";
    networkmanager.enable = true;
    useDHCP = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  profiles.manu.enable = true;

  services = {
    nginx.enable = true;
    nginx.noDefault.enable = true;
    nginx.publicDomains = [ "yali.es" "ceciliaflamenca.com" ];
    nginx.virtualHosts."yali.es".root = "/srv/sites/yali";
    nginx.virtualHosts."ceciliaflamenca.com".root = "/srv/sites/cecilia-flamenca";
    openssh.enable = true;
    tailscale.enable = true;
  };

  users.mutableUsers = true;
  users.users.camille.passwordFile = null;

  system.stateVersion = "23.11";
}

