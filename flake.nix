{
  description = "A flake for my personal configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    unstable.url = "github:camillemndn/nixpkgs/nixos-unstable";
    unstable-working.url = "github:camillemndn/nixpkgs/b47c5fe5f762dff6f68c2fa450a3c5d5db36668e";
    kernel.url = "nixpkgs/0d8145a5d81ebf6698077b21042380a3a66a11c7";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/2df0d034bc4a18fafb3524401eeeceaa6b23e753";
      inputs.nixpkgs.follows = "unstable";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "unstable";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    mobile-nixos = { url = "github:camillemndn/mobile-nixos"; flake = false; };

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

  outputs = inputs@{ ... }:
    with inputs; with builtins;
    (utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend
            (final: prev: {
              unstable = unstable.legacyPackages.${system};
              unstable-working = unstable-working.legacyPackages.${system};
            });
        in
        {
          packages = nixpkgs.lib.attrsets.filterAttrs
            (name: value: (elem (toString system) value.meta.platforms))
            (import ./pkgs/top-level { inherit pkgs; });
        }) //
    {
      deploy = import ./deploy.nix inputs;

      homeConfigurations = import ./home/configurations.nix inputs;

      nixosConfigurations = import ./configurations.nix inputs;

      nixosModules = import ./modules;

      dnsRecords.zeppelin = with unstable.lib;
        let domains = filter (hasSuffix "kms") (attrNames self.nixosConfigurations.zeppelin.config.services.nginx.virtualHosts);
        in
        {
          kms.subdomains = genAttrs (map (removeSuffix ".kms") domains) (n: { A = [ "100.100.45.24" ]; });
        };
    });
}
