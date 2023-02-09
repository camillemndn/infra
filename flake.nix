{
  description = "A flake for my personnal configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      # url = "github:nix-community/home-manager/release-22.11";
      url = "github:nix-community/home-manager/master";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    utils.url = "github:numtide/flake-utils";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.11";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-22_11.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    phps = {
      url = "github:fossar/nix-phps";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    kernel.url = "nixpkgs/bafc851daff10fdda5eb6ed068234c46baeb4d0f";
  };

  outputs = inputs@{ self, nixpkgs, unstable, home-manager, utils, deploy-rs, sops-nix, neovim-nightly-overlay, nixos-wsl, phps, ... }:
    with builtins;
    (utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend
            (final: prev: {
              unstable = unstable.legacyPackages.${system};
            });
        in
        rec {
          packages = nixpkgs.lib.attrsets.filterAttrs (name: value: (elem (toString system) value.meta.platforms)) (import ./packages { inherit pkgs; });
        }) // {
      deploy = import ./deploy.nix inputs;

      homeConfigurations = import ./home-configurations { inherit unstable home-manager; };

      nixosConfigurations = import ./configurations.nix inputs;

      nixosModules = import ./modules;

      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    }
    );
}
