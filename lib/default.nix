lib: _:

{
  hasSuffixIn = l: x: builtins.any (s: lib.hasSuffix s x) l;

  # Zones implied by public machines' nginx virtual hosts, shared by primary and secondaries.
  dnsZones =
    {
      config,
      hostName,
      machines,
      nixosConfigurations,
    }:
    rec {
      publicMachines = lib.filterAttrs (_: m: m ? ipv4.public || m ? ipv6.public) machines;

      nginxOf =
        name:
        if name == hostName then
          config.services.nginx
        else
          nixosConfigurations.${name}.config.services.nginx;

      names = lib.unique (
        lib.concatMap (name: (nginxOf name).publicDomains) (lib.attrNames publicMachines)
      );
    };
}
