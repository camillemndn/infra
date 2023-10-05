{ lib, pkgs, inputs, system, ... }:

with inputs;
let
  unstable-patched = (import unstable {
    inherit system;
  }).applyPatches {
    name = "unstable-patched";
    src = inputs.unstable;
    patches = [
      (builtins.fetchurl {
        url = "https://github.com/NixOS/nixpkgs/pull/259076.patch"; # Jellyseerr
        sha256 = "1awbxzksh2p482fw5lq9lzn92s8n224is9krz8irqc1nbd5fm5jf";
      })
    ];
  };
in

final: _: lib.updateManyAttrs [
  # Adds all the packages from this flake
  self.packages.${system}
  {
    inherit lib;
    pinned = import pinned { inherit system; inherit (pkgs) config; };
    unstable = import unstable-patched { inherit system; };

    # Adds some packages from other flakes
    hyperland = hyprland.packages.x86_64-linux.default.override { nvidiaPatches = true; };
    spicetify-nix = spicetify-nix.packages.${system}.default;
    inherit (hyprland-contrib.packages.${system}) grimblast;
    inherit (nix-software-center.packages.${system}) nix-software-center;
    inherit (attic.packages.${system}) attic;

    jellyseerr = final.unstable.jellyseerr;
    photoprism = final.unstable.photoprism;
  }
]
