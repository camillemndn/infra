let
  inherit ((import ./.)) nixosConfigurations machines;

  mkLibForMachine =
    machine: (import "${machines.${machine}.nixpkgs_version}/lib").extend (import ./lib);
in
{
  meta = {
    nodeNixpkgs = builtins.mapAttrs (n: _: import machines.${n}.nixpkgs_version) nixosConfigurations;

    nodeSpecialArgs = builtins.mapAttrs (
      n: v: v._module.specialArgs // { lib = mkLibForMachine n; }
    ) nixosConfigurations;
  };
}
// builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations
