{
  self,
  lib,
  pkgs,
}:

{
  meta = {
    nixpkgs = pkgs;
    nodeNixpkgs = builtins.mapAttrs (_: v: v.pkgs) self.nixosConfigurations;
    nodeSpecialArgs = builtins.mapAttrs (_: v: v._module.specialArgs) self.nixosConfigurations;
    specialArgs.lib = lib;
  };
}
// builtins.mapAttrs (n: v: {
  imports = v._module.args.modules;
  inherit (self.machines.${n}) deployment;
}) self.nixosConfigurations
