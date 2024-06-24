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
  pkgs = import nixpkgs { inherit system; };
in
import "${nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  lib = pkgs.lib.extend (import ./default.nix inputs);
  specialArgs = {
    inherit inputs;
  };
  modules = builtins.attrValues modules ++ [
    ../machines/base.nix
    host-config
    (import "${home-manager}/nixos")
    (import "${inputs.nixos-mailserver}")
    (import "${inputs.attic}/nixos/atticd.nix")
    (import "${inputs.disko}/module.nix")
    (import "${inputs.buildbot-nix}/nix/master.nix")
    (import "${inputs.buildbot-nix}/nix/worker.nix")
    (import "${inputs.agenix}/modules/age.nix")
    (import "${inputs.impermanence}/nixos.nix")
    (import inputs.musnix)
    (import "${inputs.sops-nix}/modules/sops")
    (import inputs.lanzaboote).nixosModules.lanzaboote
    (import inputs.lila).nixosModules.hash-collection
    (
      { config, ... }:
      {
        home-manager = {
          useGlobalPkgs = true;
          sharedModules = builtins.attrValues hmModules ++ [
            inputs.nix-index-database.hmModules.nix-index
            inputs.spicetify-nix.homeManagerModule
          ];
          users = lib.genAttrs (builtins.attrNames config.users.users) (
            user: lib.importIfExists ./${name}/home/${user}.nix
          );
        };
        nixpkgs.system = system;
        networking.hostName = name;

        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "harmony-assistant"
            "mac"
            "nvidia-settings"
            "nvidia-x11"
            "reaper"
            "spotify"
            "steam"
            "steam-original"
            "steam-run"
            "unrar"
            "zoom"
            "corefonts"
          ];

        nixpkgs.overlays = lib.mkAfter [
          (
            let
              generated = import "${inputs.nix-index-database}/generated.nix";

              nix-index-database =
                (pkgs.fetchurl {
                  url = generated.url + pkgs.stdenv.system;
                  hash = generated.hashes.${pkgs.stdenv.system};
                }).overrideAttrs
                  {
                    __structuredAttrs = true;
                    unsafeDiscardReferences.out = true;
                  };
            in
            final: prev:
            lib.updateManyAttrs [
              # Adds all the packages from this flake
              extraPackages.${system}

              {
                inherit lib;
                pinned = import inputs.nixpkgs-pinned {
                  inherit system;
                  inherit (pkgs) config;
                };
                unstable = import inputs.nixpkgs-unstable {
                  inherit system;
                  inherit (pkgs) config;
                };

                # Adds some packages from other flakes
                spicetify-nix = pkgs.callPackage "${inputs.spicetify-nix}/pkgs";
                inherit nix-index-database;
                nix-index-with-db = pkgs.callPackage "${inputs.nix-index-database}/nix-index-wrapper.nix" {
                  inherit nix-index-database;
                };
                comma-with-db = pkgs.callPackage "${inputs.nix-index-database}/comma-wrapper.nix" {
                  inherit nix-index-database;
                };
                zotero = pkgs.wrapFirefox (pkgs.callPackage "${inputs.zotero-nix}/pkgs" { }) { };
                firefoxpwa = prev.firefoxpwa.override {
                  extraLibs = with prev; [
                    alsa-lib
                    ffmpeg_5
                    libjack2
                    pipewire
                    libpulseaudio
                  ];
                };
                vimPlugins = prev.vimPlugins // final.extraVimPlugins;
                inherit (final.unstable)
                  quarto
                  typst
                  jackett
                  tandoor-recipes
                  ;
              }
            ]
          )
        ];
      }
    )
  ];
  extraModules =
    let
      colmenaModules = import "${inputs.colmena}/src/nix/hive/options.nix";
    in
    [ colmenaModules.deploymentOptions ];
}
