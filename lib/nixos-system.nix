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
  listUsers = config: builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users);
  nixpkgsTree = builtins.fetchTree {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = inputs.nixpkgs.revision;
  };
in
import "${nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  lib = pkgs.lib.extend (import ./default.nix inputs);
  specialArgs = {
    inherit inputs;
  };
  modules = builtins.attrValues modules ++ [
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
    (import inputs.lanzaboote).nixosModules.lanzaboote
    (import inputs.lila).nixosModules.hash-collection
    (
      { config, ... }:
      {
        home-manager = {
          useGlobalPkgs = true;
          sharedModules = builtins.attrValues hmModules ++ [
            (import inputs.spicetify-nix).homeManagerModules.spicetify
          ];
          users = lib.genAttrs (listUsers config) (
            user: lib.importIfExists ../machines/${name}/home-manager/${user}.nix
          );
        };
        networking.hostName = name;
        system.nixos.version = "${config.system.nixos.release}.${
          builtins.substring 0 8 nixpkgsTree.lastModifiedDate
        }.${nixpkgsTree.shortRev}";

        nixpkgs = {
          inherit system;
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
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

                  pinned =
                    import
                      (fetchTarball "https://github.com/NixOS/nixpkgs/archive/ae2fc9e0e42caaf3f068c1bfdc11c71734125e06.tar.gz")
                      {
                        inherit system;
                        inherit (prev) config;
                      };

                  unstable = import inputs.nixpkgs-unstable {
                    inherit system;
                    inherit (prev) config;
                  };
                  inherit (final.unstable)
                    jackett
                    jellyseerr
                    jitsi-meet
                    quarto
                    typst
                    zotero
                    ;

                  # Adds some packages from other flakes
                  spicetify-nix = (import inputs.spicetify-nix).legacyPackages.${system};

                  inherit nix-index-database;
                  nix-index-with-db = prev.callPackage "${inputs.nix-index-database}/nix-index-wrapper.nix" {
                    inherit nix-index-database;
                  };
                  comma-with-db = prev.callPackage "${inputs.nix-index-database}/comma-wrapper.nix" {
                    inherit nix-index-database;
                  };

                  firefoxpwa = final.unstable.firefoxpwa.override {
                    extraLibs = with final.unstable; [
                      alsa-lib
                      ffmpeg_7
                      libjack2
                      pipewire
                      libpulseaudio
                    ];
                  };

                  lubelogger = final.unstable.lubelogger.overrideAttrs (
                    _: _: {
                      makeWrapperArgs = [ "--set-default DOTNET_CONTENTROOT ${placeholder "out"}/lib/lubelogger" ];
                    }
                  );

                  vimPlugins = prev.vimPlugins // final.vim-plugins;
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
