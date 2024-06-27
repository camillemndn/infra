{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nix = {
    package = pkgs.lix;
    gc.automatic = lib.mkIf config.services.openssh.enable true;
    optimise.automatic = true;

    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "camille" ];

      auto-optimise-store = true;
      builders-use-substitutes = true;

      extra-substituters = [ "https://cache.saumon.network/camille" ];

      extra-trusted-public-keys = [ "camille:r1ElbcicaLHPlvECyy3wS+CUj4KWHaCEV2Kt1LEaYI0=" ];

      nix-path = [
        "nixpkgs=${inputs.nixpkgs}"
        "nixos=${inputs.nixpkgs}"
      ];
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    distributedBuilds = true;

    buildMachines = [
      (lib.mkIf (config.networking.hostName != "offspring") {
        hostName = lib.infra.machines.offspring.ipv4.public;
        sshUser = "root";
        system = "aarch64-linux";
        maxJobs = 8;
      })
    ];
  };
}
