{ lib, utils, ... }:

with lib;

rec {
  recursiveUpdateManyAttrs = foldl recursiveUpdate { };

  updateManyAttrs = foldl (x: y: x // y) { };

  mergeDefaultSystems = x: recursiveUpdateManyAttrs (map x utils.lib.defaultSystems);

  nixosSystem' = args@{ config, hardware, ... }: lib.nixosSystem (lib.recursiveUpdate
    {
      system = "x86_64-linux";
      inherit pkgs lib extraModules;
      specialArgs = { inherit inputs; };
      modules = [ (import ./${config}) (import ../hardware/${hardware}.nix) ];
    }
    args);
}
