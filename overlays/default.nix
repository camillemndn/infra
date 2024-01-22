{ lib, pkgs, self, system }:

with self.inputs;

final: prev: lib.updateManyAttrs [
  # Adds all the packages from this flake
  self.packages.${system}
  {
    inherit lib;
    pinned = import nixpkgs-pinned { inherit system; inherit (pkgs) config; };
    unstable = import nixpkgs-unstable { inherit system; inherit (pkgs) config; };

    # Adds some packages from other flakes
    spicetify-nix = spicetify-nix.packages.${system}.default;
    inherit (nix-software-center.packages.${system}) nix-software-center;
    inherit (attic.packages.${system}) attic;
    inherit (zotero-nix.packages.${system}) zotero;
    firefoxpwa = prev.firefoxpwa.override { extraLibs = with prev; [ alsa-lib ffmpeg_5 libjack2 pipewire libpulseaudio ]; };
    vimPlugins = prev.vimPlugins // final.extraVimPlugins;
    jackett = final.unstable.jackett;
  }
]
