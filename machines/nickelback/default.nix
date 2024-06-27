_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "nickelback";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  profiles = {
    cache-client.enable = false;
    manu.enable = true;
  };

  services = {
    nginx.enable = true;
    nginx.noDefault.enable = true;
    nginx.publicDomains = [
      "yali.es"
      "ceciliaflamenca.com"
    ];
    nginx.virtualHosts."yali.es".root = "/srv/sites/yali";
    nginx.virtualHosts."ceciliaflamenca.com".root = "/srv/sites/cecilia-flamenca";
    openssh.enable = true;
    tailscale.enable = true;
  };

  users.mutableUsers = true;
  users.users.camille.hashedPasswordFile = null;
  sops.secrets = { };

  system.stateVersion = "23.11";
}
