{ lib, pkgs, extraModules, extraHomeModules, self, nixpkgs, system, ... }:

let
  nixosSystem' =
    args@{ configuration
    , hardware
    , users
    , ...
    }: lib.nixosSystem (lib.recursiveUpdate
      {
        inherit lib;
        specialArgs = { inherit self nixpkgs; };
        modules = extraModules ++ [
          (import ./${configuration})
          (import ../hardware/${hardware})
          {
            nixpkgs = { inherit pkgs; };

            home-manager = {
              useGlobalPkgs = true;
              sharedModules = extraHomeModules;
              users = lib.genAttrs users (user: lib.importIfExists ./${configuration}/home/${user}.nix);
            };
          }
        ];
      }
      (builtins.removeAttrs args [ "configuration" "hardware" "users" ]));

  mapSystemsFromMachines = lib.mapAttrs (configuration: args: nixosSystem' {
    inherit configuration;
    inherit (args) hardware;
    users = args.users or [ "camille" ];
  });

in
mapSystemsFromMachines (lib.filterAttrs (configuration: args: builtins.pathExists ./${configuration} && system == args.system or "x86_64-linux") self.machines)
