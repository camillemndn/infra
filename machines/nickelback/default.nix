_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "nickelback";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
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

    openssh = {
      enable = true;
      extraConfig = ''
        Match User manu
        PasswordAuthentication yes 
      '';
    };

    tailscale.enable = true;
  };

  users.users.manu = {
    isNormalUser = true;
    description = "Manu";
  };

  system.stateVersion = "23.11";
}
