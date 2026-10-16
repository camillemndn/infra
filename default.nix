let
  inputs = import ./inputs.nix;

  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib);

  modulesIn =
    dir:
    lib.mapAttrsToList (entry: _: dir + "/${entry}") (
      lib.filterAttrs (entry: type: type == "directory" || lib.hasSuffix ".nix" entry) (
        builtins.readDir dir
      )
    );

  packages = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
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
      specialArgs = { inherit inputs packages; };
      modules =
        modulesIn ./nixos ++ modulesIn (./hosts + "/${name}") ++ [ { networking.hostName = name; } ];
      extraModules = [ (import "${inputs.colmena}/src/nix/hive/options.nix").deploymentOptions ];
    }
  ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));
in

{
  inherit packages nixosConfigurations;

  checks = {
    inherit packages;
    machines = builtins.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations;
  };
}
