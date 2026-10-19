{
  config,
  hosts,
  inputs,
  lib,
  packages,
  pkgs,
  ...
}:

let
  sshPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmuMNGkWQ7ozpC2UU0+jqMsRw1zVgT2Q9ORmLcTXpK2 camille@zeppelin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f camille@genesis"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWvUwCcmmjEFfE2cNE14w/ZPm9odzVUrKwTNAOR+UZR camille@thelonious"
  ];

  email = "camillemondon@free.fr";
  keys = config.users.users.camille.openssh.authorizedKeys.keys;

  # Trusted commit signers, for git and for comin: camille from any of their
  # machines, and the bot that opens the daily lon update.
  signers =
    map (key: {
      inherit email;
      key = lib.concatStringsSep " " (lib.take 2 (lib.splitString " " key));
    }) keys
    ++ [
      {
        email = "lon-bot@git.mndn.fr";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJma0AITkBgjbrIdrG8YGkB01Q/gtBqXxh/OMneofOy";
      }
    ];

  # Re-patched with this machine's pkgs, so the NIX_PATH copy builds on the target.
  patchedNixpkgs =
    if inputs.nixpkgs ? patches then
      pkgs.applyPatches { inherit (inputs.nixpkgs) name src patches; }
    else
      inputs.nixpkgs;

  nixpkgsRevision = (builtins.fromJSON (builtins.readFile ../../lon.lock)).sources.nixpkgs.revision;
in

{
  imports = [
    "${inputs.agenix}/modules/age.nix"
    # Written for flakes; the package is set in nixos/comin instead of from `self`.
    (import "${inputs.comin}/nix/module.nix" { self.packages = { }; })
    "${inputs.home-manager}/nixos"
    (import inputs.stylix).nixosModules.stylix
  ];

  options.networking.addresses = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };

  config = {
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
    console.keyMap = "fr";

    environment = {
      etc."ssh/allowed_signers".text = lib.concatMapStrings (
        s: "${s.email} namespaces=\"git\" ${s.key}\n"
      ) signers;

      systemPackages = with pkgs; [
        attic-client
        comma-with-db
        dig
        dust
        fastfetch
        htop
        lazygit
        lsof
        nh
        nix-init
        nix-output-monitor
        nix-tree
        nix-update
        nixos-option
        nmap
        ntfs3g
        oh-my-fish
        powertop
        tldr
        unzip
        wget
        zip
      ];
    };

    hardware = {
      enableRedistributableFirmware = lib.mkDefault true;

      # Both images go in the initrd; each CPU loads only its vendor's.
      cpu = lib.genAttrs [ "amd" "intel" ] (_: {
        updateMicrocode = lib.mkDefault (
          config.hardware.enableRedistributableFirmware && pkgs.stdenv.hostPlatform.isx86
        );
      });
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";

      sharedModules = [
        (
          { lib, ... }:

          {
            home.language.base = "fr_FR.UTF-8";

            programs = {
              fish.enable = true;
              home-manager.enable = true;
            };

            home.stateVersion = lib.mkDefault "24.05";
          }
        )
      ];

      users = lib.genAttrs (builtins.attrNames (
        lib.filterAttrs (_: u: u.isNormalUser) config.users.users
      )) (_: { });
    };

    i18n = {
      defaultLocale = "fr_FR.UTF-8";

      extraLocaleSettings = {
        LANG = "fr_FR.UTF-8";
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_ALL = "fr_FR.UTF-8";
        LC_CTYPE = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MESSAGES = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };
    };

    networking = {
      networkmanager.enable = lib.mkDefault true;
      nftables.enable = true;
    };

    nix = {
      buildMachines = [
        {
          hostName = hosts.offspring.ipv4.public;
          sshUser = "root";
          system = "aarch64-linux";
          maxJobs = 2;
        }
      ];

      channel.enable = false;
      distributedBuilds = true;

      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';

      gc = {
        automatic = lib.mkDefault true;
        dates = "weekly";
      };

      nixPath = [
        "nixpkgs=${patchedNixpkgs}"
        "nixos=${patchedNixpkgs}"
      ];

      settings = {
        auto-optimise-store = true;
        builders-use-substitutes = true;

        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-users = [ "camille" ];
      };
    };

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";

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

            inherit nix-index-database;

            nix-index-with-db = prev.callPackage "${inputs.nix-index-database}/nix-index-wrapper.nix" {
              inherit nix-index-database;
            };

            comma-with-db = prev.callPackage "${inputs.nix-index-database}/comma-wrapper.nix" {
              inherit nix-index-database;
            };
          }
        )
      ];
    };

    programs = {
      direnv.enable = true;

      fish = {
        enable = true;

        promptInit = ''
          ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
        '';
      };

      git = {
        enable = true;

        config = {
          user = {
            name = "Camille M.";
            inherit email;
          };

          gpg = {
            format = "ssh";
            ssh.allowedSignersFile = "/etc/ssh/allowed_signers";
          };

          pull.rebase = true;
          fetch.prune = true;
          rebase.autoStash = true;
          push.autoSetupRemote = true;
          diff.colorMoved = true;
        };
      };

      nix-index = lib.mkDefault {
        enable = true;
        package = pkgs.nix-index-with-db;
      };

      # Unattended builds can't accept unknown host keys, and offspring's sshd penalises dropped connections.
      ssh.knownHosts.offspring = {
        hostNames = [
          hosts.offspring.ipv4.public
          hosts.offspring.ipv6.public
        ];

        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTQP1XL41AvmwxYaoFSAK6p8X9NPdMg8jppRspeV4cy";
      };

      tmux = {
        enable = true;
        terminal = "xterm-kitty";
        extraConfig = builtins.readFile ./tmux.conf;

        plugins = with pkgs.tmuxPlugins; [
          catppuccin
          yank
          sensible
          pain-control
          resurrect
          prefix-highlight
        ];
      };
    };

    security.pki.certificateFiles = [ ./saumonnet.crt ];

    services = {
      openssh = {
        enable = lib.mkDefault true;
        settings.PasswordAuthentication = lib.mkDefault false;
      };

      resolved = {
        enable = true;

        settings.Resolve = {
          DNSOverTLS = "opportunistic";
          DNSSEC = "allow-downgrade";
        };
      };

      tailscale = {
        enable = lib.mkDefault true;
        # Accepts other nodes' routes; loosens the reverse-path filter for them.
        useRoutingFeatures = lib.mkDefault "client";
      };
    };

    system.nixos.version = "${config.system.nixos.release}.${builtins.substring 0 7 nixpkgsRevision}";
    time.timeZone = lib.mkOverride 500 "Europe/Paris";

    users = {
      defaultUserShell = pkgs.fish;

      users = {
        camille = {
          isNormalUser = true;
          description = "Camille";

          extraGroups = [
            "audio"
            "lp"
            "networkmanager"
            "pipewire"
            "scanner"
            "wheel"
          ];

          openssh.authorizedKeys.keys = sshPubKeys;
        };

        root.openssh.authorizedKeys.keys = sshPubKeys;
      };
    };
  };
}
