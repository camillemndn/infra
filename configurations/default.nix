{ lib, pkgs, extraModules, extraHomeModules, self, nixpkgs, ... }:

let
  nixosSystem' =
    args@{ configuration
    , hardware
    , users ? [ "camille" ]
    , system ? "x86_64-linux"
    , ...
    }: lib.nixosSystem (lib.recursiveUpdate
      {
        inherit lib;
        specialArgs = { inherit self; };
        modules = extraModules ++ [
          (import ./${configuration})
          (import ../hardware/${hardware})
          {
            nixpkgs = {
              inherit (pkgs) config;
              overlays = [ self.overlays.${system} ];
            };

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
    system = args.system or "x86_64-linux";
  });

in
(mapSystemsFromMachines (lib.filterAttrs (configuration: _: builtins.pathExists ./${configuration}) self.machines)) //
{
  # pinkfloyd = nixosSystem' {
  #   configuration = "pinkfloyd";
  #   hardware = "pine64/pinephone";
  #   system = "aarch64-linux";
  #   modules = [
  #     (import "${mobile-nixos}/lib/configuration.nix" { device = "pine64-pinephone"; })
  #     "${mobile-nixos}/examples/phosh/phosh.nix"
  #     (import ./pinkfloyd)
  #   ];
  # };

  # radiogagaImage = nixosSystem' {
  #   configuration = "radiogaga";
  #   hardware = "raspberrypi/3b";
  #   system = "aarch64-linux";
  #   modules = [
  #     "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  #     { sdImage.firmwareSize = 512; }
  #   ];
  # };
}

