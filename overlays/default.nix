{ lib, pkgs, inputs, system, ... }:

with inputs;

final: prev: lib.updateManyAttrs [
  # Adds all the packages from this flake
  self.packages.${system}
  {
    inherit lib;
    pinned = import pinned { inherit system; inherit (pkgs) config; };
    unstable = unstable.legacyPackages.${system};

    # Adds some packages from other flakes
    hyperland = hyprland.packages.x86_64-linux.default.override { nvidiaPatches = true; };
    spicetify-nix = spicetify-nix.packages.${system}.default;
    inherit (hyprland-contrib.packages.${system}) grimblast;
    inherit (nix-software-center.packages.${system}) nix-software-center;

    photoprism = final.unstable.photoprism;
  }
]
