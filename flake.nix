{
  description = "A flake for my personal configurations";

  inputs = {
    # Nix packages

    nixpkgs.url = "github:camillemndn/nixpkgs/nixos-23.05";
    pinned.url = "github:camillemndn/nixpkgs/b47c5fe5f762dff6f68c2fa450a3c5d5db36668e";
    unstable.url = "github:camillemndn/nixpkgs/nixos-unstable";

    # Flake utils

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    utils = { url = "flake-utils"; inputs.systems.follows = "systems"; };
    systems = { url = "path:./systems.nix"; flake = false; };

    # Necessary dependencies

    home-manager = { url = "home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    lanzaboote.url = "github:nix-community/lanzaboote";
    mobile-nixos = { url = "github:camillemndn/mobile-nixos"; flake = false; };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    # Other apps

    hyprland = { url = "github:hyprwm/Hyprland?ref=v0.26.0"; inputs.nixpkgs.follows = "nixpkgs"; };
    hyprland-contrib = { url = "github:hyprwm/contrib"; inputs.nixpkgs.follows = "nixpkgs"; };

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

  outputs = inputs@{ ... }: with inputs;
    let
      lib = nixpkgs.lib.extend (final: prev: import ./lib { lib = prev; inherit utils; });
    in
    lib.mergeDefaultSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnsupportedSystem = true;
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "mac"
            "corefonts"
            "unrar"
            "filerun"
            "spotify"
            "steam"
            "steam-original"
            "steam-run"
            "nvidia-x11"
            "nvidia-settings"
            "zoom"
          ];
        };

        extraHomeModules = lib.attrValues self.homeManagerModules ++ [
          spicetify-nix.homeManagerModule
          hyprland.homeManagerModules.default
        ] ++ (import ./home/profiles);

        extraModules = lib.attrValues self.nixosModules ++ [
          home-manager.nixosModules.home-manager
          hyprland.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          nixos-wsl.nixosModules.wsl
          simple-nixos-mailserver.nixosModule
          sops-nix.nixosModules.sops
        ] ++ (import ./profiles);
      in
      {
        inherit lib pkgs;

        packages.${system} = import ./pkgs/top-level { inherit pkgs; };
        overlays.default = final: prev: lib.updateManyAttrs [
          { inherit lib; }
          {
            pinned = pinned.legacyPackages.${system};
            unstable = unstable.legacyPackages.${system};
          }
          # Adds all the packages from this flake
          self.packages.${system}
          # Adds some packages from other flakes
          {
            grimblast = hyprland-contrib.packages.x86_64-linux.grimblast;
            hyperland = hyprland.packages.x86_64-linux.default.override { nvidiaPatches = true; };
            nix-software-center = nix-software-center.packages.${system}.default;
            spicetify-nix = spicetify-nix.packages.${system}.default;
          }
        ];

        machines = import ./machines.nix;

        homeConfigurations = import ./configurations/home.nix { inherit (inputs) self home-manager; inherit lib pkgs extraHomeModules; };
        homeManagerModules = import ./home/modules;

        nixosConfigurations = import ./configurations { inherit (inputs) self; inherit lib pkgs extraModules extraHomeModules; };
        nixosModules = import ./modules;

        deploy = import ./deploy.nix { inherit (inputs) self deploy-rs; };
      });
}
