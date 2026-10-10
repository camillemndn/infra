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

let
  # The patched nixpkgs from inputs.nix is built for the evaluating machine; re-apply the
  # same patches with this machine's pkgs so the NIX_PATH copy builds on the target.
  nixpkgs =
    if inputs.nixpkgs ? patches then
      pkgs.applyPatches { inherit (inputs.nixpkgs) name src patches; }
    else
      inputs.nixpkgs;
in
{
  nix = {
    # package = pkgs.lix;

    buildMachines = [
      (lib.mkIf (config.networking.hostName != "offspring") {
        hostName = offspringMeta.ipv4.public;
        sshUser = "root";
        system = "aarch64-linux";
        maxJobs = 2;
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
      "nixpkgs=${nixpkgs}"
      "nixos=${nixpkgs}"
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

  # Remote builds run unattended and cannot accept an unknown host key; offspring's sshd
  # penalises every connection that drops before authenticating.
  programs.ssh.knownHosts.offspring = {
    hostNames = [
      offspringMeta.ipv4.public
      offspringMeta.ipv6.public
    ];
    publicKey = offspringMeta.hostKey;
  };
}
