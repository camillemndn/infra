{ lib, pkgs, inputs, system, ... }:

with inputs;

_final: _: lib.updateManyAttrs [
  # Adds all the packages from this flake
  self.packages.${system}
  {
    inherit lib;
    pinned = import nixpkgs-pinned { inherit system; inherit (pkgs) config; };

    # Adds some packages from other flakes
    spicetify-nix = spicetify-nix.packages.${system}.default;
    inherit (hyperland.packages.${system}) xdg-desktop-portal-hyprland;
    inherit (hyprland-contrib.packages.${system}) grimblast;
    inherit (nix-software-center.packages.${system}) nix-software-center;
    inherit (attic.packages.${system}) attic;
  }
]
