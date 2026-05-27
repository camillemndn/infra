inputs: lib: _:

{
  importConfig =
    path:
    (builtins.mapAttrs (name: _value: import (path + "/${name}/default.nix")) (
      lib.filterAttrs (_: v: v == "directory") (builtins.readDir path)
    ));

  hasSuffixIn = l: x: builtins.any (s: lib.hasSuffix s x) l;

  updateManyAttrs = lib.foldl (x: y: x // y) { };

  importIfExists = p: if (builtins.pathExists p) then import p else _: { };
}
