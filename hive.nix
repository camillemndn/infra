let
  inputs = import ./inputs.nix;

  inherit (import ./.) nixosConfigurations;
in

{
  meta = {
    nixpkgs = import inputs.nixpkgs { };

    nodeSpecialArgs = builtins.mapAttrs (
      _: v: v._module.specialArgs // { lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib); }
    ) nixosConfigurations;
  };
}
// builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations
