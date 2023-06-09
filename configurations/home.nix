{ lib, pkgs, extraHomeModules, self, home-manager, ... }:

let
  homeManagerConfiguration' = args@{ user, configuration, ... }: home-manager.lib.homeManagerConfiguration (lib.recursiveUpdate
    {
      inherit pkgs lib;
      # specialArgs = { inherit self; };
      modules = extraHomeModules ++ [ (import ./${configuration}/home/${user}.nix) ];
    }
    (builtins.removeAttrs args [ "configuration" "user" ]));

  mapHmConfigFromMachines = lib.mapAttrs'
    (configuration: args: lib.nameValuePair
      "camille@${configuration}"
      (homeManagerConfiguration' { inherit configuration; user = "camille"; })
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
