{
  lib,
  pkgs,
  self,
  extraModules,
  extraHomeModules,
  nixpkgs,
  system,
}:

let
  nixosSystem =
    args:
    import "${nixpkgs}/nixos/lib/eval-config.nix" (
      args
      // {
        modules = args.modules ++ [
          {
            system.nixos.versionSuffix = ".${
              lib.substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101")
            }.${self.shortRev or "dirty"}";
            system.nixos.revision = lib.mkIf (self ? rev) self.rev;
          }
        ];
      }
      // lib.optionalAttrs (!args ? system) {
        # Allow system to be set modularly in nixpkgs.system.
        # We set it to null, to remove the "legacy" entrypoint's
        # non-hermetic default.
        system = null;
      }
    );

  nixosSystem' =
    args@{
      configuration,
      hardware,
      users,
      ...
    }:
    nixosSystem (
      lib.recursiveUpdate
        {
          inherit lib;
          specialArgs = {
            inherit self nixpkgs;
          };
          modules = extraModules ++ [
            (import ./${configuration})
            (import ../hardware/${hardware})
            {
              nixpkgs = {
                inherit pkgs;
              };

              home-manager = {
                useGlobalPkgs = true;
                sharedModules = extraHomeModules;
                users = lib.genAttrs users (user: lib.importIfExists ./${configuration}/home/${user}.nix);
              };
            }
          ];
        }
        (
          builtins.removeAttrs args [
            "configuration"
            "hardware"
            "users"
          ]
        )
    );

  mapSystemsFromMachines = lib.mapAttrs (
    configuration: args:
    nixosSystem' {
      inherit configuration;
      inherit (args) hardware;
      users = args.users or [ "camille" ];
    }
  );
in
mapSystemsFromMachines (
  lib.filterAttrs (
    configuration: args:
    builtins.pathExists ./${configuration} && system == args.system or "x86_64-linux"
  ) self.machines
)
