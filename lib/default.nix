{ lib, utils, ... }:

with lib;

rec {
  recursiveUpdateManyAttrs = foldl recursiveUpdate { };

  updateManyAttrs = foldl (x: y: x // y) { };

  mergeDefaultSystems = x: recursiveUpdateManyAttrs (map x utils.lib.defaultSystems);

  platformMatches = x: sys: filterAttrs (name: pkg: (elem sys pkg.meta.platforms)) x;
}
