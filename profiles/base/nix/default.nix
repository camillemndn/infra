{ config, lib, self, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "camille" ];

      substituters = [
        "https://cache.mondon.xyz?priority=45"
        "https://cache2.mondon.xyz?priority=45"
      ];

      trusted-public-keys = [
        "cache.mondon.xyz:6o1j93GkK5gj0PfYouSA4WPAEEnOuPGTebLCWc/jKfQ="
        "cache2.mondon.xyz:8zCLL6cuq3rX66LpesMMQRticIrMsewHXzl8NmPUvfs="
      ];

      nix-path = [ "nixpkgs=flake:nixpkgs/nixos-23.05" ];
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    distributedBuilds = true;

    buildMachines = [
      (lib.mkIf (config.networking.hostName != "zeppelin") {
        hostName = self.machines.zeppelin.ipv6.public;
        sshUser = "root";
        system = "x86_64-linux";
        maxJobs = 24;
      })
      (lib.mkIf (config.networking.hostName != "offspring") {
        hostName = self.machines.offspring.ipv4.public;
        sshUser = "root";
        system = "aarch64-linux";
        maxJobs = 8;
      })
    ];
  };

  programs.command-not-found.enable = false;
  programs.nix-index-database.comma.enable = true;
}
