# Wraps lon.nix with an optional patch overlay.
#
# Drop one or more .diff / .patch files into  patches/<input-name>/
# and they'll be applied (via nixpkgs' applyPatches) to that input's
# source. No `patches/<name>/` directory → input is passed through
# unchanged. The unpatched nixpkgs from lon is used to provide the
# applyPatches helper, so patches/nixpkgs/ works without bootstrapping
# loops.

let
  raw = import ./lon.nix;

  bootstrapPkgs = import raw.nixpkgs {
    system = builtins.currentSystem or "x86_64-linux";
    config = { };
    overlays = [ ];
  };

  patchesDir = ./patches;

  patchesFor =
    name:
    let
      dir = patchesDir + "/${name}";
      isPatch = n: builtins.match ".*\\.(diff|patch)" n != null;
    in
    if builtins.pathExists dir then
      map (n: dir + "/${n}") (builtins.filter isPatch (builtins.attrNames (builtins.readDir dir)))
    else
      [ ];

  applyIfPatches =
    name: src:
    let
      patches = patchesFor name;
    in
    if patches == [ ] then
      src
    else
      bootstrapPkgs.applyPatches {
        name = "${name}-patched";
        inherit src patches;
      };
in

builtins.mapAttrs applyIfPatches raw
