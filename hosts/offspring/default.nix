{ lib, ... }:

{
  networking = {
    addresses = {
      ipv4 = {
        # The cloud provider's NAT address; the instance only sees `local`.
        local = "10.0.0.163";
        public = "158.178.204.106";
      };

      ipv6.public = "2603:c027:c002:702:a0c:c8e:cc5e:c723";
    };

    domain = "mndn.fr";
    networkmanager.enable = false;
  };

  # Its own builds stay local.
  nix.buildMachines = lib.mkForce [ ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICu2PXuhmCpgkN3b0jWQIbNpYBDlzhGbeSpbK+k4nbRO camille@offspring"
  ];

  services = {
    nginx.enable = true;
    tailscale.enable = false;
  };

  system.stateVersion = "23.05";
}
