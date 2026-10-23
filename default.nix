let
  inputs = import ./inputs.nix;
  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib);

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  unstable = lib.genAttrs systems (system: import inputs.nixpkgs-unstable { inherit system; });

  packages = lib.genAttrs systems (
    system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "harmony-assistant" ];
      };

      callPackage = pkgs.lib.customisation.callPackageWith (pkgs // ownPackages);

      ownPackages = builtins.mapAttrs (pname: _: callPackage (./pkgs + "/${pname}") { }) (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./pkgs)
      );
    in
    lib.filterAttrs (
      _: drv: !(drv ? meta.platforms) || builtins.elem system drv.meta.platforms
    ) ownPackages
  );

  nixosConfigurations = builtins.mapAttrs (
    name: _:
    import "${inputs.nixpkgs}/nixos/lib/eval-config.nix" {
      system = null;
      inherit lib;

      specialArgs = {
        inherit
          hosts
          inputs
          nixosConfigurations
          packages
          ;
      };

      modules =
        lib.modulesIn ./nixos
        ++ lib.modulesIn (./hosts + "/${name}")
        ++ [ { networking.hostName = name; } ];

      extraModules = [ (import "${inputs.colmena}/src/nix/hive/options.nix").deploymentOptions ];
    }
  ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));

  # Read from each host's default.nix with placeholder arguments, so no host's
  # NixOS configuration is evaluated to know another host's addresses.
  hosts = builtins.mapAttrs (
    name: _:
    let
      module = import (./hosts + "/${name}/default.nix");

      attrs =
        if builtins.isFunction module then
          module (builtins.mapAttrs (_: _: null) (builtins.functionArgs module))
        else
          module;
    in
    attrs.networking.addresses or { }
  ) nixosConfigurations;

  hive = {
    meta = {
      nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };

      nodeSpecialArgs = builtins.mapAttrs (
        _: host: host._module.specialArgs // { inherit lib; }
      ) nixosConfigurations;
    };
  }
  // builtins.mapAttrs (_: host: { imports = host._module.args.modules; }) nixosConfigurations;
in

{
  inherit packages nixosConfigurations;

  checks = lib.genAttrs systems (
    system:
    packages.${system}
    // lib.mapAttrs' (name: host: lib.nameValuePair "nixos-${name}" host.config.system.build.toplevel) (
      lib.filterAttrs (_: host: host.pkgs.stdenv.hostPlatform.system == system) nixosConfigurations
    )
  );

  colmena = hive;
  colmenaHive = import "${inputs.colmena}/src/nix/hive/eval.nix" { rawHive = hive; };

  devShells = lib.genAttrs systems (
    system:
    let
      pkgs = unstable.${system};

      gitHooks =
        (import "${inputs.git-hooks}/nix" {
          inherit system;
          nixpkgs = inputs.nixpkgs-unstable;
        }).run
          {
            src = ./.;

            hooks = {
              deadnix.enable = true;
              statix.enable = true;

              rfc101 = {
                enable = true;
                name = "RFC-101 formatting";
                entry = lib.getExe pkgs.nixfmt;
                files = "\\.nix$";
              };

              blank-lines = {
                enable = true;
                name = "Blank lines between bindings";
                entry = "${pkgs.python3.interpreter} ${./scripts/blank-lines.py}";
                files = "\\.nix$";
                excludes = [ "^lon\\.nix$" ];
              };

              commitizen.enable = true;
            };
          };
    in
    {
      default = pkgs.mkShell {
        nativeBuildInputs = [
          (pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { })
          (import ./scripts/nixos-anywhere.nix { inherit inputs pkgs; })
          pkgs.colmena
          pkgs.lon
          pkgs.nix-init
          pkgs.nix-update
          pkgs.statix
        ];

        shellHook = ''
          ${gitHooks.shellHook}
          statix fix
        '';
      };
    }
  );

  formatter = lib.genAttrs systems (system: unstable.${system}.nixfmt);
}
