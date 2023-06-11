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

  platformMatches = x: sys: filterAttrs (_: pkg: elem sys pkg.meta.platforms) x;

  # Paths

  importIfExists = p: if (builtins.pathExists p) then import p else _: { };
}
