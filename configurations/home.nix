{ lib, pkgs, extraHomeModules, self, home-manager, nixpkgs, ... }:

let
  homeManagerConfiguration' = args@{ user, configuration, system, ... }: home-manager.lib.homeManagerConfiguration (lib.recursiveUpdate
    {
      inherit lib;
      pkgs = import nixpkgs { inherit system; inherit (pkgs) config overlays; };
      extraSpecialArgs = { inherit self; };
      modules = extraHomeModules ++ [ (import ./${configuration}/home/${user}.nix) ];
    }
    (builtins.removeAttrs args [ "configuration" "user" "system" ]));

  mapHmConfigFromMachines = lib.mapAttrs'
    (configuration: args:
      let system = args.system or "x86_64-linux"; in
      lib.nameValuePair
        "camille@${configuration}"
        (homeManagerConfiguration' { inherit configuration system; user = "camille"; })
    );

in
mapHmConfigFromMachines self.machines

# let
# username = "camille";
# homeDirectory = "/home/${username}";
# configHome = "${homeDirectory}/.config";

# pkgs = import nixpkgs {
# inherit system;
# config.allowUnfree = true;
# config.xdg.configHome = configHome;
# overlays = [ .overlay ];
# };
# in
# {
#   "camille@genesis" = home-manager.lib.homeManagerConfiguration {
#     inherit pkgs;
#     modules = extraHomeModules ++ [
#       ./genesis/home/camille.nix
#     ];
#   };
# }
