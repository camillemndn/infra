{
  description = "A flake for my personal configurations";

  inputs = {
    # Nix packages and modules

    nixpkgs.url = "nixpkgs/nixos-23.05";
    pinned.url = "nixpkgs/85bcb95aa83be667e562e781e9d186c57a07d757";
    unstable.url = "nixpkgs/nixos-unstable";
    home-manager = { url = "home-manager/release-23.05"; inputs.nixpkgs.follows = "nixpkgs"; };

    # Flake utils

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    utils = { url = "flake-utils"; inputs.systems.follows = "systems"; };
    systems = { url = "https://raw.githubusercontent.com/camillemndn/nixos-config/main/systems.nix"; flake = false; };

    # Hardware dependencies

    lanzaboote.url = "github:nix-community/lanzaboote/45d04a45d3dfcdee5246f7c0dfed056313de2a61";
    mobile-nixos = { url = "github:camillemndn/mobile-nixos"; flake = false; };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    # Sofware dependencies 

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    hyprland = { url = "github:hyprwm/Hyprland?ref=v0.28.0"; }; # inputs.nixpkgs.follows = "unstable"; };
    hyprland-contrib = { url = "github:hyprwm/contrib"; }; # inputs.nixpkgs.follows = "unstable"; };

    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-23_05.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
  };

  outputs = inputs: with inputs;

    let lib = nixpkgs.lib.extend (_: prev: import ./lib { lib = prev; inherit utils; }); in

    lib.mergeDefaultSystems (system:

      let
        nixpkgs-patched = (import nixpkgs {
          inherit system;
        }).applyPatches {
          name = "nixpkgs-patched";
          src = nixpkgs;
          patches = [
            (builtins.fetchurl {
              url = "https://github.com/NixOS/nixpkgs/pull/227588.patch"; # Jitsi
              sha256 = "0zh6hxb2m7wg45ji8k34g1pvg96235qmfnjkrya6scamjfi1j19l";
            })
            ./patches/firefoxpwa.patch # Firefox PWA
          ];
        };

        pkgs = import nixpkgs-patched {
          inherit system;
          overlays = [ self.overlays.${system} ];
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "corefonts"
            "harmony-assistant"
            "mac"
            "nvidia-settings"
            "nvidia-x11"
            "spotify"
            "steam"
            "steam-original"
            "steam-run"
            "unrar"
            "zoom"
          ];
        };

        baseModules = import (nixpkgs-patched + "/nixos/modules/module-list.nix");

        extraHomeModules = lib.attrValues self.homeManagerModules ++ [
          hyprland.homeManagerModules.default
          nix-index-database.hmModules.nix-index
          spicetify-nix.homeManagerModule
        ] ++ (import ./profiles/home);

        extraModules = lib.attrValues self.nixosModules ++ [
          home-manager.nixosModules.home-manager
          #hyprland.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          nix-index-database.nixosModules.nix-index
          nixos-wsl.nixosModules.wsl
          simple-nixos-mailserver.nixosModule
          sops-nix.nixosModules.sops
        ] ++ (import ./profiles);
      in

      {
        packages.${system} = import ./pkgs/top-level { inherit pkgs; };

        overlays.${system} = import ./overlays { inherit lib pkgs inputs system; };

        machines = import ./machines.nix;

        homeConfigurations = import ./configurations/home.nix {
          inherit lib pkgs extraHomeModules;
          inherit self home-manager nixpkgs;
        };

        homeManagerModules = import ./modules/home;

        nixosConfigurations = import ./configurations {
          inherit lib pkgs baseModules extraModules extraHomeModules;
          inherit self nixpkgs mobile-nixos;
        };

        nixosModules = import ./modules;

        colmena = import ./colmena.nix { inherit lib pkgs self; };

        devShell.${system} = pkgs.mkShell {
          buildInputs = with pkgs; [
            age
            sops
            colmena
            nixos-generators
          ];
        };
      });
}
