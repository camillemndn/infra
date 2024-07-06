_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "offspring";
    firewall.allowedTCPPorts = [ 2022 ];
  };

  deployment.targetHost = "offspring.mondon.xyz";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICu2PXuhmCpgkN3b0jWQIbNpYBDlzhGbeSpbK+k4nbRO camille@offspring"
  ];

  services = {
    openssh.enable = true;
    nginx.enable = true;
    nginx.noDefault.enable = true;
    uptime-kuma.enable = true;
  };

  system.stateVersion = "23.05";
}
