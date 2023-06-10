{ lib, pkgs, extraHomeModules, self, home-manager, nixpkgs, ... }:

let
  homeManagerConfiguration' =
    args@{ user
    , configuration
    , system ? "x86_64-linux"
    , ...
    }: home-manager.lib.homeManagerConfiguration (lib.recursiveUpdate
      {
        inherit lib;
        pkgs = import nixpkgs { inherit system; inherit (pkgs) config overlays; };
        extraSpecialArgs = { inherit self; };
        modules = extraHomeModules ++ [
          (lib.importIfExists ./${configuration}/home/${user}.nix)
          { home = { username = user; homeDirectory = "/home/${user}"; }; }
        ];
      }
      (builtins.removeAttrs args [ "configuration" "user" "system" ]));

  mkHmConfigFromUsers = configuration: args:
    lib.genAttrs (args.users or [ "camille" ])
      (user: homeManagerConfiguration' {
        inherit user configuration;
        system = args.system or "x86_64-linux";
      });

  mapHmConfigsFromMachines = x: lib.flattenAttrs
    (config: user: user + "@" + config)
    (lib.mapAttrs mkHmConfigFromUsers x);
in
mapHmConfigsFromMachines self.machines
