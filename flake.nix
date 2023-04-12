{
  description = "A flake for my personnal configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    unstable.url = "github:camillemndn/nixpkgs/nixos-unstable";
    kernel.url = "nixpkgs/4c83fe7ec352c9b81cf8220bd1653a1bce970069";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "unstable";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "unstable";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    phps = {
      url = "github:fossar/nix-phps";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-22.11";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-22_11.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "utils";
    };

    utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ nixpkgs, unstable, utils, ... }:
    with builtins;
    (utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend
            (final: prev: {
              unstable = unstable.legacyPackages.${system};
            });
        in
        {
          packages = nixpkgs.lib.attrsets.filterAttrs
            (name: value: (elem (toString system) value.meta.platforms))
            (import ./pkgs/top-level { inherit pkgs; });
        }) //
    {
      deploy = import ./deploy.nix inputs;

      homeConfigurations = import ./home/configurations inputs;

      nixosConfigurations = import ./configurations.nix inputs;

      nixosModules = import ./modules;

      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    });
}
