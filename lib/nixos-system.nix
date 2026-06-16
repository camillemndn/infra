inputs: lib:

{
  name,
  host-config,
  modules,
  hmModules,
  nixpkgs ? inputs.nixpkgs,
  extraPackages,
  system ? "x86_64-linux",
  home-manager ? inputs.home-manager,
}:

let
  listUsers = config: builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users);

  nixpkgsLock = (builtins.fromJSON (builtins.readFile ../lon.lock)).sources.nixpkgs;
  nixpkgsVersion = builtins.substring 0 7 nixpkgsLock.revision;
in

import "${nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  lib = (import "${nixpkgs}/lib").extend (import ./default.nix inputs);

  specialArgs = {
    inherit inputs;
  };

  modules = builtins.attrValues modules ++ [
    host-config
    (import "${home-manager}/nixos")
    (import "${inputs.disko}/module.nix")
    (import "${inputs.buildbot-nix}/nix/master.nix")
    (import "${inputs.buildbot-nix}/nix/worker.nix")
    (import "${inputs.agenix}/modules/age.nix")
    (import "${inputs.impermanence}/nixos.nix")
    (import "${inputs.nix-minecraft}/modules/minecraft-servers.nix")
    (import inputs.lanzaboote { inherit system; }).nixosModules.lanzaboote
    (import inputs.musnix)
    (import inputs.stylix).nixosModules.stylix
    (import inputs.nixvim).nixosModules.nixvim

    (
      { config, ... }:
      {
        networking.hostName = name;

        system.nixos.version = "${config.system.nixos.release}.${nixpkgsVersion}";

        home-manager = {
          useGlobalPkgs = true;
          sharedModules = builtins.attrValues hmModules;
          users = lib.genAttrs (listUsers config) (
            user: lib.importIfExists ../machines/${name}/home-manager/${user}.nix
          );
        };

        nixpkgs = {
          inherit system;
          config = {
            permittedInsecurePackages = [
            ];
            allowUnfreePredicate =
              let
                cudaLicenseNames = [
                  "CUDA EULA"
                  "cuDNN EULA"
                  "cuSPARSELt EULA"
                  "cuTENSOR EULA"
                  "NVIDIA Math SDK SLA"
                  "TensorRT EULA"
                ];
              in
              pkg:
              builtins.elem (lib.getName pkg) [
                "corefonts"
                "cups-brother-hll2340dw"
                "libsane-dsseries"
                "minecraft-server"
                "nvidia-settings"
                "nvidia-x11"
                "samsung-unified-linux-driver"
                "spotify"
                "steam"
                "steam-original"
                "steam-run"
                "steam-unwrapped"
              ]
              || lib.all (license: license.free || lib.elem (license.shortName or null) cudaLicenseNames) (
                lib.toList pkg.meta.license
              );
          };
          overlays = lib.mkAfter [
            (import "${inputs.nix-minecraft}/overlay.nix")
            (
              final: prev:
              let
                generated = import "${inputs.nix-index-database}/generated.nix";
                nix-index-database =
                  (prev.fetchurl {
                    url = generated.url + prev.stdenv.system;
                    hash = generated.hashes.${prev.stdenv.system};
                  }).overrideAttrs
                    {
                      __structuredAttrs = true;
                      unsafeDiscardReferences.out = true;
                    };
              in
              lib.updateManyAttrs [
                # Adds all the packages from this flake
                extraPackages.${system}

                {
                  inherit lib;

                  unstable = import inputs.nixpkgs-unstable {
                    inherit system;
                    inherit (prev) config;
                  };
                  inherit (final.unstable)
                    feishin
                    firefoxpwa
                    nextcloud-client
                    ocrmypdf
                    quarto
                    signalbackup-tools
                    zotero
                    ;

                  # Adds some packages from other flakes
                  inherit nix-index-database;
                  nix-index-with-db = prev.callPackage "${inputs.nix-index-database}/nix-index-wrapper.nix" {
                    inherit nix-index-database;
                  };
                  comma-with-db = prev.callPackage "${inputs.nix-index-database}/comma-wrapper.nix" {
                    inherit nix-index-database;
                  };

                  vimPlugins =
                    prev.vimPlugins // (lib.filterAttrs (_: v: v.vimPlugin or false) extraPackages.${system});
                }
              ]
            )
          ];
        };
      }
    )
  ];

  extraModules =
    let
      colmenaModules = import "${inputs.colmena}/src/nix/hive/options.nix";
    in
    [ colmenaModules.deploymentOptions ];
}
