lib: _:

{
  # Zones implied by public machines' nginx virtual hosts, shared by primary and secondaries.
  dnsZones =
    {
      config,
      hosts,
      nixosConfigurations,
    }:
    rec {
      configOf =
        name: if name == config.networking.hostName then config else nixosConfigurations.${name}.config;

      nginxOf = name: (configOf name).services.nginx;
      publicMachines = lib.filterAttrs (_: m: m ? ipv4.public || m ? ipv6.public) hosts;

      names = lib.unique (
        lib.concatMap (name: (nginxOf name).publicDomains) (lib.attrNames publicMachines)
      );
    };

  hasSuffixIn = l: x: builtins.any (s: lib.hasSuffix s x) l;

  modulesIn =
    dir:
    lib.mapAttrsToList (entry: _: dir + "/${entry}") (
      lib.filterAttrs (entry: type: type == "directory" || lib.hasSuffix ".nix" entry) (
        builtins.readDir dir
      )
    );
}
