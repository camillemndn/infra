{
  config,
  hosts,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Re-patched with this machine's pkgs, so the NIX_PATH copy builds on the target.
  nixpkgs =
    if inputs.nixpkgs ? patches then
      pkgs.applyPatches { inherit (inputs.nixpkgs) name src patches; }
    else
      inputs.nixpkgs;
in
{
  nix = {
    buildMachines = [
      (lib.mkIf (config.networking.hostName != "offspring") {
        hostName = hosts.offspring.ipv4.public;
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

  # Unattended builds can't accept unknown host keys, and offspring's sshd penalises dropped connections.
  programs.ssh.knownHosts.offspring = {
    hostNames = [
      hosts.offspring.ipv4.public
      hosts.offspring.ipv6.public
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTQP1XL41AvmwxYaoFSAK6p8X9NPdMg8jppRspeV4cy";
  };
}
