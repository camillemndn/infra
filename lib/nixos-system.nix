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
    inputs.lanzaboote.nixosModules.lanzaboote
    (import inputs.musnix)
    inputs.niri-flake.nixosModules.niri
    (import inputs.stylix).nixosModules.stylix
    (import inputs.nixvim).nixosModules.nixvim

    (
      { config, pkgs, ... }:
      {
        networking.hostName = name;

        home-manager = {
          useGlobalPkgs = true;
          sharedModules =
            builtins.attrValues hmModules
            ++ lib.optionals (!config.stylix.enable) [
              inputs.stylix.homeModules.stylix
            ];
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

                  papermc = prev.callPackage "${inputs.nixpkgs}/pkgs/games/papermc/derivation.nix" {
                    version = "1.21.11-69";
                    hash = "sha256-zzdPKvnXHfzHU0Pze3IqerywkcV0ExuV47E8b8LLj64=";
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
