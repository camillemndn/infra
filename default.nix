let
  inputs = import ./deps;
  patch = import inputs.nix-patches { patchFile = ./patches; };
  inputs_final = inputs // {
    nixpkgs_patched = patch.mkNixpkgsSrc {
      src = inputs.unstable;
      version = "nixos-unstable";
    };
  };
  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib inputs_final);
  mkLibForMachine =
    machine:
    (import "${lib.infra.machines.${machine}.nixpkgs_version}/lib").extend (import ./lib inputs_final);
  machines_plats = lib.lists.unique (
    lib.mapAttrsToList (_name: value: value.system) (
      lib.filterAttrs (_n: v: builtins.hasAttr "system" v) lib.infra.machines
    )
  );

  nixosSystem = import ./lib/nixos-system.nix inputs_final lib;

  nixpkgs_plats = builtins.listToAttrs (
    builtins.map (plat: {
      name = plat;
      value = import inputs.nixpkgs {
        system = plat;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "harmony-assistant" ];
      };
    }) machines_plats
  );
in
rec {
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
      nixpkgs = lib.infra.machines.${name}.nixpkgs_version;
      extraPackages = packages;
      inherit (lib.infra.machines.${name}) system;
      home-manager = lib.infra.machines.${name}.hm_version;
    })
  ) (lib.importConfig ./machines);

  colmena = {
    meta = {
      nodeNixpkgs = builtins.mapAttrs (
        n: _: import lib.infra.machines.${n}.nixpkgs_version
      ) nixosConfigurations;
      nodeSpecialArgs = builtins.mapAttrs (
        n: v: v._module.specialArgs // { lib = mkLibForMachine n; }
      ) nixosConfigurations;
    };
  } // builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations;

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
            let
              callPackage = nixpkgs_plats.${plat}.lib.customisation.callPackageWith (
                nixpkgs_plats.${plat} // ours
              );
              ours = builtins.listToAttrs (
                builtins.map (e: {
                  name = e;
                  value = callPackage (./pkgs + "/${e}") { };
                }) (builtins.attrNames (builtins.readDir ./pkgs))
              );
            in
            ours
          );
    }) machines_plats
  );

  inherit (lib.infra) machines;

  checks = {
    inherit packages;
    machines = lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations;
  };
}
