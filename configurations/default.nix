{ lib, pkgs, extraModules, extraHomeModules, self, ... }:

let
  nixosSystem' = args@{ configuration, hardware, users, system, ... }: lib.nixosSystem (lib.recursiveUpdate
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
            users = lib.genAttrs users (user: import ./${configuration}/home/${user}.nix);
          };
        }
      ];
    }
    (builtins.removeAttrs args [ "configuration" "hardware" "users" ]));

  mapSystemFromMachines = lib.mapAttrs
    (configuration: args:
      let system = args.system or "x86_64-linux"; in
      nixosSystem' { inherit configuration system; inherit (args) hardware users; });

in
(mapSystemFromMachines self.machines) //
{

  # pinkfloyd = nixosSystem' "pinkfloyd" "pine64/pinephone" {
  #   system = "aarch64-linux";
  #   modules = [
  #     { home-manager.users.camille = import ./home/configurations/base inputs; }
  #     (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "pine64-pinephone"; })
  #     "${inputs.mobile-nixos}/examples/phosh/phosh.nix"
  #   ];
  # };


  # radiogagaImage = nixosSystem' "radiogaga" "raspberrypi/3b" {
  #   system = "aarch64-linux";
  #   modules = [
  #     "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  #     { sdImage.firmwareSize = 512; }
  #   ];
}
