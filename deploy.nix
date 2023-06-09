{ self, deploy-rs, ... }:

{
  sshUser = "root";
  user = "root";
  remoteBuild = true;

  nodes = {
    genesis = {
      hostname = "localhost";
      profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.genesis;
    };

    offspring = {
      hostname = "offspring.mondon.xyz";
      profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.offspring;
    };

    radiogaga = {
      hostname = "radiogaga.kms";
      profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.radiogaga;
      remoteBuild = false;
    };

    rush = {
      hostname = "rush.kms";
      profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rush;
    };

    zeppelin = {
      hostname = "zeppelin.kms";
      profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zeppelin;
    };
  };
}
