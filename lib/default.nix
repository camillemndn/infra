{ lib, utils, ... }:

with lib;

rec {
  # Strings

  hasSuffixIn = l: x: elem true (map (s: hasSuffix s x) l);

  # Attribute sets
  recursiveUpdateManyAttrs = foldl recursiveUpdate { };

  updateManyAttrs = foldl (x: y: x // y) { };

  genAttrs' = names: f: listToAttrs (map f names);

  flattenAttrs = f: concatMapAttrs (n: v: mapAttrs' (v: val: nameValuePair (f n v) val) v);

  # Flake utils

  mergeDefaultSystems = x: recursiveUpdateManyAttrs (map x utils.lib.defaultSystems);

  patchNixpkgs = system: nixpkgs: patches: (import nixpkgs { inherit system; }).applyPatches {
    name = "nixpkgs-patched";
    src = nixpkgs;
    patches = attrValues patches;
  };

  # Paths

  importIfExists = p: if (builtins.pathExists p) then import p else _: { };
}
