{
  config,
  inputs,
  lib,
  packages,
  ...
}:

{
  system.nixos = {
    versionSuffix = ".${
      builtins.substring 0 8 inputs.nixpkgs.lastModifiedDate
    }.${inputs.nixpkgs.shortRev}";
    revision = inputs.nixpkgs.rev;
  };

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "pnpm-9.15.9"
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
        packages.${config.nixpkgs.hostPlatform.system}
        // {
          inherit lib;

          unstable = import inputs.nixpkgs-unstable {
            inherit (config.nixpkgs.hostPlatform) system;
            inherit (prev) config;
          };

          inherit (final.unstable)
            feishin
            firefoxpwa
            nextcloud-client
            ocrmypdf
            quarto
            signalbackup-tools
            ;

          # Zotero 10 needs Firefox ESR 140, dropped from unstable: https://github.com/NixOS/nixpkgs/issues/568692
          inherit
            (import
              (fetchTarball {
                url = "https://github.com/NixOS/nixpkgs/archive/f45c6f04c2f013f004bf94e284e95d72898d9393.tar.gz";
                sha256 = "081f0i3lav0gmwad7vmmpxlrjs4aa7gwz4sm0anrxcclgpnyfkga";
              })
              {
                inherit (config.nixpkgs.hostPlatform) system;
                inherit (prev) config;
              }
            )
            zotero
            ;

          panache = prev.panache.overrideAttrs (
            finalAttrs: _: {
              version = "3.10.0";

              src = prev.fetchFromGitHub {
                owner = "jolars";
                repo = "panache";
                tag = "v${finalAttrs.version}";
                hash = "sha256-13v2J7qRgkX55vjFt0daU26J/IhmECCr1H0fVEW72rk=";
              };

              cargoDeps = prev.rustPlatform.fetchCargoVendor {
                inherit (finalAttrs) src;
                name = "panache-${finalAttrs.version}";
                hash = "sha256-D8SfoPjfIHnrvjYG6lJbqAHL1jkAI5st2105OP9md6s=";
              };
            }
          );

          inherit (inputs.nix-index-database.packages.${config.nixpkgs.hostPlatform.system})
            nix-index-database
            nix-index-with-db
            comma-with-db
            ;
        }
      )
    ];
  };
}
