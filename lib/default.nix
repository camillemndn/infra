inputs: lib: _:

with builtins;

{
  importConfig =
    path:
    (mapAttrs (name: _value: import (path + "/${name}/default.nix")) (
      lib.filterAttrs (_: v: v == "directory") (readDir path)
    ));

  infra = import ./infra.nix inputs lib;

  hasSuffixIn = l: x: elem true (map (s: lib.hasSuffix s x) l);

  updateManyAttrs = lib.foldl (x: y: x // y) { };

  importIfExists = p: if (builtins.pathExists p) then import p else _: { };
}
