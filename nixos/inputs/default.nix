{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    "${inputs.agenix}/modules/age.nix"
    "${inputs.buildbot-nix}/nix/master.nix"
    "${inputs.buildbot-nix}/nix/worker.nix"
    "${inputs.disko}/module.nix"
    "${inputs.lanzaboote}/nix/modules/lanzaboote.nix"
    "${inputs.nix-minecraft}/modules/minecraft-servers.nix"
    "${inputs.stateless-uptime-kuma}/nixos/module.nix"
    (import inputs.nixvim).nixosModules.nixvim
    (import inputs.stylix).nixosModules.stylix
  ];
  boot.lanzaboote.package =
    lib.mkDefault
      (import inputs.lanzaboote {
        inherit (pkgs.stdenv.hostPlatform) system;
      }).packages.lzbt;
}
