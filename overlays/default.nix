{ lib, pkgs, inputs, system, ... }:

with inputs;

_: prev: lib.updateManyAttrs [
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

    thunderbird-bin-unwrapped = prev.thunderbird-bin-unwrapped.overrideAttrs (_:
      let version = "116.0a1"; in {
        inherit version;
        src = pkgs.fetchurl {
          url = "https://ftp.mozilla.org/pub/thunderbird/nightly/latest-comm-central-l10n/thunderbird-${version}.fr.linux-x86_64.tar.bz2";
          sha256 = "sha256-556n/7KWMAERoovXsG6ulDLQQoUTk1XAfVporpUk7Js=";
        };
      });
  }
]
