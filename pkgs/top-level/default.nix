{ pkgs, ... }:

import ./all-packages.nix { inherit pkgs; } //
import ./python-packages.nix { inherit pkgs; }
