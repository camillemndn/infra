(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    inherit (lock.nodes.flake-compat.locked) narHash rev;
  in
  fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${rev}.tar.gz";
    sha256 = narHash;
  }
) { src = ./.; }).defaultNix
