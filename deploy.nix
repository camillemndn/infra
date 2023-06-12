{ self, lib, deploy-rs, ... }:

{
  sshUser = "root";
  user = "root";
  remoteBuild = true;

  nodes = lib.mapAttrs
    (machine: config: {
      hostname = config.ipv6.vpn or config.ipv4.vpn or config.ipv6.public or config.ipv4.public;
      profiles.system.path = deploy-rs.lib.${config.system or "x86_64-linux"}.activate.nixos self.nixosConfigurations.${machine};
      remoteBuild = config.remoteBuild or true;
    })
    self.machines;
}
