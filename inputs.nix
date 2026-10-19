# lon.nix inputs, with patches/<input>/*.{diff,patch} applied.
# The unpatched nixpkgs applies them, so patches/nixpkgs works too.

let
  raw = import ./lon.nix;

  bootstrapPkgs = import raw.nixpkgs {
    config = { };
    overlays = [ ];
    system = builtins.currentSystem or "x86_64-linux";
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
        inherit src patches;
        name = "${name}-patched";
      };
in

builtins.mapAttrs applyIfPatches raw
