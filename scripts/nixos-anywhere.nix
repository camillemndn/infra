let
  inputs = import ../deps;
  pkgs = import inputs.nixpkgs { };
  nixos-anywhere = pkgs.callPackage "${inputs.nixos-anywhere}/src/default.nix" { };
in
pkgs.writeShellScriptBin "nixos-anywhere" ''
  set -euo pipefail
  pushd $(git rev-parse --show-toplevel)
  machine=$1
  ssh_connection=$2
  extra_args=("''${@:3}")


  if [ "$ssh_connection" == "--vm-test" ]; then
    exec nix-build \
        -A nixosConfigurations."$machine".config.system.build.installTest
  else
    exec ${nixos-anywhere}/bin/nixos-anywhere \
      --store-paths $(nix-build -A nixosConfigurations."$machine".config.system.build.diskoScript) \
      $(nix-build -A nixosConfigurations."$machine".config.system.build.toplevel) \
      "''${extra_args[@]}" "$ssh_connection"
  fi
  popd
''
