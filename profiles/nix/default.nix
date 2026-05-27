let
  offspringMeta = import ../../machines/offspring/meta.nix;
in
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nix = {
    # package = pkgs.lix;

    buildMachines = [
      (lib.mkIf (config.networking.hostName != "offspring") {
        hostName = offspringMeta.ipv4.public;
        sshUser = "root";
        system = "aarch64-linux";
        maxJobs = 8;
      })
    ];

    channel.enable = false;

    distributedBuilds = true;

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    gc = {
      automatic = lib.mkIf config.services.openssh.enable true;
      dates = "weekly";
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "nixos=${inputs.nixpkgs}"
    ];

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "camille" ];
    };
  };
}
