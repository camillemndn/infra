{
  description = "A flake for my personal configurations";

  inputs = {
    ### Nix packages and modules ###
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-pinned.url = "nixpkgs/fdd898f8f79e8d2f99ed2ab6b3751811ef683242";
    home-manager = { url = "home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    ################################

    ### Flake utils ###
    colmena.url = "github:zhaofengli/colmena";
    utils = { url = "flake-utils"; inputs.systems.follows = "systems"; };
    systems = { url = "https://raw.githubusercontent.com/camillemndn/nixos-config/main/systems.nix"; flake = false; };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ###################

    ### Hardware dependencies ###
    lanzaboote.url = "github:nix-community/lanzaboote/45d04a45d3dfcdee5246f7c0dfed056313de2a61";
    mobile-nixos = { url = "github:camillemndn/mobile-nixos"; flake = false; };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
    #############################

    ### Sofware dependencies ###
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    hyprland = { url = "github:hyprwm/Hyprland?ref=v0.30.0"; inputs.nixpkgs.follows = "nixpkgs"; };
    hyprland-contrib = { url = "github:hyprwm/contrib"; inputs.nixpkgs.follows = "nixpkgs"; };

    musnix.url = "github:musnix/musnix";

    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
    ############################
  };

  outputs = inputs: with inputs;

    let lib = nixpkgs.lib.extend (_: prev: import ./lib { lib = prev; inherit utils; }); in

    lib.mergeDefaultSystems (system:

      let
        nixpkgs = lib.patchNixpkgs system inputs.nixpkgs self.patches;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.${system} ];
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "corefonts"
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
          ];
        };

        extraHomeModules = lib.attrValues self.homeManagerModules ++ [
          hyprland.homeManagerModules.default
          nix-index-database.hmModules.nix-index
          spicetify-nix.homeManagerModule
        ] ++ (import ./profiles/home);

        extraModules = lib.attrValues self.nixosModules ++ [
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          musnix.nixosModules.musnix
          nix-index-database.nixosModules.nix-index
          nixos-wsl.nixosModules.wsl
          simple-nixos-mailserver.nixosModule
          sops-nix.nixosModules.sops
        ] ++ (import ./profiles);
      in

      {
        packages.${system} = import ./pkgs/top-level { inherit pkgs; };

        overlays.${system} = import ./overlays { inherit lib pkgs self system; };

        patches = {
          clevis = ./overlays/clevis.patch;
          firefoxpwa = builtins.fetchurl {
            url = "https://github.com/NixOS/nixpkgs/pull/263404.patch";
            sha256 = "0p56nkdwddajk5ays2msny23aar3k5f4mnhq6wp5did2pq44ap35";
          };
          jellyseerr = builtins.fetchurl {
            url = "https://github.com/NixOS/nixpkgs/pull/259076.patch";
            sha256 = "1awbxzksh2p482fw5lq9lzn92s8n224is9krz8irqc1nbd5fm5jf";
          };
          jitsi-meet = builtins.fetchurl {
            url = "https://github.com/NixOS/nixpkgs/pull/227588.patch";
            sha256 = "0zh6hxb2m7wg45ji8k34g1pvg96235qmfnjkrya6scamjfi1j19l";
          };
          mattermost-desktop = builtins.fetchurl {
            url = "https://github.com/NixOS/nixpkgs/pull/259351.patch";
            sha256 = "0ikgpbs7zmcm7rg2d62wx24d0byr6vpvv11xxpxpkl5js2309cay";
          };
          mupdf = builtins.fetchurl {
            url = "https://github.com/NixOS/nixpkgs/pull/261113.patch";
            sha256 = "1qh60lzl1c5d4r7b2v7xdw0fan037mdxpfp0x4gzfkxrbhdhv73k";
          };
        };

        machines = import ./machines.nix;

        homeManagerModules = import ./modules/home;

        nixosModules = import ./modules;

        homeConfigurations = import ./configurations/home.nix {
          inherit lib pkgs self extraHomeModules;
        };

        nixosConfigurations = import ./configurations {
          inherit lib pkgs self nixpkgs extraModules extraHomeModules system;
        };

        colmena = import ./colmena.nix { inherit lib pkgs self; };

        devShells.${system}.default = pkgs.mkShell { buildInputs = with pkgs; [ home-manager age colmena nixos-generators nix-update sops ]; };
      });
}
