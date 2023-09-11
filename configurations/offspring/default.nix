_:

{
  networking = {
    hostName = "offspring";
    firewall.allowedTCPPorts = [ 2022 ];
  };

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICu2PXuhmCpgkN3b0jWQIbNpYBDlzhGbeSpbK+k4nbRO camille@offspring" ];

  services = {
    openssh.enable = true;
    nginx.noDefault.enable = true;
    nginx.virtualHosts."pln.camille.mondon.xyz".root = "/srv/www/slides";
  };

  profiles = {
    binary-cache = { enable = false; hostName = "cache2.mondon.xyz"; };
    uptime.enable = true;
  };

  system.stateVersion = "23.05";
}

