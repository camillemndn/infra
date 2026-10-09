inputs: lib: _:

{
  importConfig =
    path:
    (builtins.mapAttrs (name: _value: import (path + "/${name}/default.nix")) (
      lib.filterAttrs (_: v: v == "directory") (builtins.readDir path)
    ));

  hasSuffixIn = l: x: builtins.any (s: lib.hasSuffix s x) l;

  updateManyAttrs = lib.foldl (x: y: x // y) { };

  importIfExists = p: if (builtins.pathExists p) then import p else _: { };

  # The zones implied by the nginx virtual hosts of every publicly reachable
  # machine. The signer and the secondaries derive their zone list from here,
  # so they always agree on which names are served.
  dnsZones =
    {
      config,
      hostName,
      machines,
      nixosConfigurations,
      foreignZones ? [ ],
    }:
    rec {
      publicMachines = lib.filterAttrs (_: m: m ? ipv4.public || m ? ipv6.public) machines;

      nginxOf =
        name:
        if name == hostName then
          config.services.nginx
        else
          nixosConfigurations.${name}.config.services.nginx;

      names = lib.subtractLists foreignZones (
        lib.unique (lib.concatMap (name: (nginxOf name).publicDomains) (lib.attrNames publicMachines))
      );
    };
}
