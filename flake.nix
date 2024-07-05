{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
    in
    {

      packages = builtins.listToAttrs (
        builtins.map (plat: {
          name = plat;
          value =
            lib.filterAttrs
              (
                _name: value:
                (
                  !lib.hasAttrByPath [
                    "meta"
                    "platforms"
                  ] value
                )
                || builtins.elem plat value.meta.platforms
              )
              (
                builtins.listToAttrs (
                  builtins.map (e: {
                    name = e;
                    value = nixpkgs.legacyPackages.${plat}.callPackage (./pkgs + "/${e}") { };
                  }) (builtins.attrNames (builtins.readDir ./pkgs))
                )
              );
        }) [ "x86_64-linux" ]
      );
    };
}
