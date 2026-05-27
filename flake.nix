{
  description = "Camille's NixOS infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    agenix.url = "github:ryantm/agenix";
    buildbot-nix.url = "github:camillemndn/buildbot-nix";
    colmena.url = "github:zhaofengli/colmena";
    disko.url = "github:nix-community/disko";
    gradle2nix.url = "github:milahu/gradle2nix/pull69-patch1";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    impermanence.url = "github:nix-community/impermanence";
    musnix.url = "github:musnix/musnix";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixvim.url = "github:nix-community/nixvim";
    stylix.url = "github:nix-community/stylix";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/b6365a70ade72f33ffb590af592cc22cfffd898d";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
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

      checks = lib.genAttrs machines_plats (
        plat:
        packages.${plat}
        // lib.mapAttrs (_: v: v.config.system.build.toplevel) (
          lib.filterAttrs (_: v: v.config.nixpkgs.system == plat) nixosConfigurations
        )
      );

      devShells = lib.genAttrs machines_plats (
        plat:
        let
          pkgs = nixpkgs_plats.${plat};
          agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
          nixos-anywhere = import ./scripts/nixos-anywhere.nix { inherit pkgs inputs; };
          pre-commit-hook = inputs.git-hooks.lib.${plat}.run {
            src = ./.;

            hooks = {
              statix.enable = true;
              rfc101 = {
                enable = true;
                name = "RFC-101 formatting";
                entry = "${pkgs.lib.getExe pkgs.nixfmt}";
                files = "\\.nix$";
              };
              commitizen.enable = true;
            };
          };
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              agenix
              colmena
              nixos-anywhere
              statix
            ];
            shellHook = ''
              ${pre-commit-hook.shellHook}
              statix fix
            '';
          };
        }
      );
    in
    {
      inherit
        packages
        nixosModules
        homeManagerModules
        nixosConfigurations
        checks
        devShells
        ;

      inherit machines;
    };
}
