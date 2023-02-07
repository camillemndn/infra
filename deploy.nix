inputs:
with inputs;
{
  sshUser = "root";
  user = "root";
  remoteBuild = true;

  nodes = {
    offspring = {
      hostname = "offspring.saumon.network";
      profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.offspring;
    };

    radiogaga = {
      hostname = "radiogaga.lan";
      profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.radiogaga;
    };

    rush = {
      hostname = "rush.kms";
      profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rush;
    };

    genesis = {
      hostname = "localhost";
      profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.genesis;
    };

    zeppelin = {
      hostname = "zeppelin.kms";
      profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zeppelin;
    };
  };
}
