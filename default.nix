let
  inputs = import ./lon.nix;

  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib inputs);

  machines = builtins.mapAttrs (
    name: _:
    lib.recursiveUpdate {
      hostname = name;
      system = "x86_64-linux";
      nixpkgs_version = inputs.nixpkgs;
      hm_version = inputs.home-manager;
      tld = "kms";
    } (import (./machines + "/${name}/meta.nix"))
  ) (lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./machines));

  machines_plats = lib.lists.unique (
    lib.mapAttrsToList (_name: value: value.system) (
      lib.filterAttrs (_n: v: builtins.hasAttr "system" v) machines
    )
  );

  nixosSystem = import ./lib/nixos-system.nix inputs lib;

  nixpkgs_plats = builtins.listToAttrs (
    builtins.map (plat: {
      name = plat;
      value = import inputs.nixpkgs {
        system = plat;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "harmony-assistant" ];
        overlays = [
          (_: prev: {
            gradle2nix = prev.callPackage inputs.gradle2nix { };
            nix-update-script =
              args:
              prev.nix-update-script (
                args
                // {
                  extraArgs = [
                    "-f"
                    "release.nix"
                  ]
                  ++ args.extraArgs or [ ];
                }
              );
          })
        ];
      };
    }) machines_plats
  );

  nixosModules =
    import ./modules
    // (builtins.listToAttrs (
      map (x: {
        name = "profile-${x}";
        value = import (./profiles + "/${x}");
      }) (builtins.attrNames (builtins.readDir ./profiles))
    ));

  homeManagerModules = builtins.listToAttrs (
    map (x: {
      name = "profile-${x}";
      value = import (./profiles/home-manager + "/${x}");
    }) (builtins.attrNames (builtins.readDir ./profiles/home-manager))
  );

  nixosConfigurations = builtins.mapAttrs (
    name: value:
    (nixosSystem {
      inherit name;
      host-config = value;
      modules = nixosModules;
      hmModules = homeManagerModules;
      nixpkgs = machines.${name}.nixpkgs_version;
      extraPackages = packages;
      inherit (machines.${name}) system;
      home-manager = machines.${name}.hm_version;
    })
  ) (lib.importConfig ./machines);

  packages = lib.genAttrs machines_plats (
    plat:
    let
      callPackage = nixpkgs_plats.${plat}.lib.customisation.callPackageWith (
        nixpkgs_plats.${plat} // extraPackages
      );

      extraPackages = builtins.mapAttrs (pname: _: callPackage (./pkgs + "/${pname}") { }) (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./pkgs)
      );
    in
    lib.filterAttrs (
      _: drv: !(drv ? meta.platforms) || builtins.elem plat drv.meta.platforms
    ) extraPackages
  );

  checks = {
    inherit packages;
    machines = lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations;
  };
in

{
  inherit
    packages
    nixosModules
    homeManagerModules
    nixosConfigurations
    checks
    ;

  inherit machines;
}
