{ config, pkgs, lib, ... }:

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

      nix-path = [ "nixpkgs=flake:nixpkgs" ];
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    distributedBuilds = true;

    buildMachines = [
      (lib.mkIf (config.networking.hostName != "zeppelin") {
        hostName = "zeppelin.kms";
        sshUser = "root";
        system = "x86_64-linux";
        maxJobs = 24;
      })
      (lib.mkIf (config.networking.hostName != "offspring") {
        hostName = "offspring.saumon.network";
        sshUser = "root";
        system = "aarch64-linux";
        maxJobs = 8;
      })
    ];
  };

  programs.command-not-found.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "mac"
    "corefonts"
    "unrar"
    "filerun"
    "spotify"
    "discord"
    "steam"
    "steam-original"
    "steam-run"
    "nvidia-x11"
    "nvidia-settings"
    "zoom"
  ];
}
