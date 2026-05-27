let
  flake = import ./.;
  inherit (flake) nixosConfigurations machines inputs;

  mkLibForMachine =
    machine: (import "${machines.${machine}.nixpkgs_version}/lib").extend (import ./lib inputs);
in
{
  meta = {
    nodeNixpkgs = builtins.mapAttrs (n: _: import machines.${n}.nixpkgs_version) nixosConfigurations;

    nodeSpecialArgs = builtins.mapAttrs (
      n: v: v._module.specialArgs // { lib = mkLibForMachine n; }
    ) nixosConfigurations;
  };

  defaults =
    { config, lib, ... }:
    {
      deployment.targetHost = lib.mkDefault machines.${config.networking.hostName}.ipv6.public;
    };
}
// builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations
