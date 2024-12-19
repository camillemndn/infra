let
  inputs = import ./deps;

  lib = (import "${inputs.nixpkgs}/lib").extend (import ./lib inputs);

  mkLibForMachine =
    machine:
    (import "${lib.infra.machines.${machine}.nixpkgs_version}/lib").extend (import ./lib inputs);

  inherit ((import ./.)) nixosConfigurations;
in
{
  meta = {
    nodeNixpkgs = builtins.mapAttrs (
      n: _: import lib.infra.machines.${n}.nixpkgs_version
    ) nixosConfigurations;

    nodeSpecialArgs = builtins.mapAttrs (
      n: v: v._module.specialArgs // { lib = mkLibForMachine n; }
    ) nixosConfigurations;
  };

  defaults =
    { config, lib, ... }:
    {
      deployment.targetHost = lib.mkDefault lib.infra.machines.${config.networking.hostName}.ipv6.public;
    };
}
// builtins.mapAttrs (_: v: { imports = v._module.args.modules; }) nixosConfigurations
