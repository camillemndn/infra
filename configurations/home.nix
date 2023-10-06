{ lib, pkgs, extraHomeModules, self, home-manager, ... }:

let
  homeManagerConfiguration' =
    args@{ user
    , configuration
    , ...
    }: home-manager.lib.homeManagerConfiguration (lib.recursiveUpdate
      {
        inherit lib pkgs;
        extraSpecialArgs = { inherit self; };
        modules = extraHomeModules ++ [
          (lib.importIfExists ./${configuration}/home/${user}.nix)
          { home = { username = user; homeDirectory = "/home/${user}"; }; }
        ];
      }
      (builtins.removeAttrs args [ "configuration" "user" ]));

  mkHmConfigFromUsers = configuration: args:
    lib.genAttrs (args.users or [ "camille" ])
      (user: homeManagerConfiguration' {
        inherit user configuration;
      });

  mapHmConfigsFromMachines = x: lib.flattenAttrs
    (config: user: user + "@" + config)
    (lib.mapAttrs mkHmConfigFromUsers x);
in
mapHmConfigsFromMachines self.machines
