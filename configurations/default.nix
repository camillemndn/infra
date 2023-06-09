{ self, lib, pkgs, extraModules, extraHomeModules, ... }:

let
  nixosSystem' = args@{ configuration, hardware, users, ... }: lib.nixosSystem (lib.recursiveUpdate
    {
      system = "x86_64-linux";
      inherit pkgs lib extraModules;
      # specialArgs = { inherit self; };
      modules = [
        (import ./${configuration})
        (import ../hardware/${hardware}.nix)
        {
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
mapSystemFromMachines self.machines
# {
#   genesis = nixosSystem' "genesis" "asus-laptop" {
#     modules = [
#       { home-manager.users.camille = import ./home/configurations/genesis inputs; }
#     ];
#   };
# 
#   icecube = nixosSystem' "icecube" "external-usb" {
#     modules = [
#       { home-manager.users.camille = import ./home/configurations/icecube inputs; }
#     ];
#   };
# 
#   offspring = nixosSystem' "offspring" "oracle-vm" { system = "aarch64-linux"; };
# 
#   pinkfloyd = nixosSystem' "pinkfloyd" "pinephone" {
#     system = "aarch64-linux";
#     modules = [
#       { home-manager.users.camille = import ./home/configurations/base inputs; }
#       (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "pine64-pinephone"; })
#       (import "${inputs.mobile-nixos}/examples/phosh/phosh.nix")
#     ];
#   };
# 
#   radiogaga = nixosSystem' "radiogaga" "raspberrypi-3b" { system = "aarch64-linux"; };
# 
#   # radiogagaImage = nixosSystem' "radiogaga" "raspberrypi-3b" {
#   #   system = "aarch64-linux";
#   #   modules = [
#   #     "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
#   #     { sdImage.firmwareSize = 512; }
#   #   ];
#   # };
# 
#   rush = nixosSystem' "rush" "raspberrypi-4b" { system = "aarch64-linux"; };
# 
#   wutang = nixosSystem' "wutang" "wsl" {
#     modules = [{ home-manager.users.camille = import ./home/configurations/base inputs; }];
#   };
# 
#   zeppelin = nixosSystem' "zeppelin" "proxmox-vm" {
#     modules = [
#       { home-manager.users.camille = import ./home/configurations/base inputs; }
#     ];
#   };
# }
