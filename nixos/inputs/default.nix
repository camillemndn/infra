{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixvim.nixosModules.nixvim
    "${inputs.nix-minecraft}/modules/minecraft-servers.nix"
    "${inputs.stateless-uptime-kuma}/nixos/module.nix"
    (import inputs.stylix).nixosModules.stylix
  ];
}
