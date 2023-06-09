{
  description = "A flake for my personal configurations";

  inputs = {
    nixpkgs.url = "github:camillemndn/nixpkgs/nixos-23.05";
    unstable.url = "github:camillemndn/nixpkgs/nixos-unstable";
    unstable-working.url = "github:camillemndn/nixpkgs/b47c5fe5f762dff6f68c2fa450a3c5d5db36668e";
    kernel.url = "nixpkgs/0d8145a5d81ebf6698077b21042380a3a66a11c7";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/2df0d034bc4a18fafb3524401eeeceaa6b23e753";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    mobile-nixos = { url = "github:camillemndn/mobile-nixos"; flake = false; };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.05";
      inputs.nixpkgs.follows = "unstable";
      inputs.nixpkgs-23_05.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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


      machines = {
        offspring = {
          ipv4.public = "141.145.197.42";
          ipv6 = { };
          subdomains = [ "offspring.mondon.xyz" ];
        };
        radiogaga = {
          tld = "kms";
          ipv4 = {
            public = "129.199.158.3";
            vpn = "100.100.45.19";
          };
          ipv6 = { };
        };
        zeppelin = {
          tld = "kms";
          ipv4 = {
            local = "192.168.0.137";
            public = "78.194.168.230";
            vpn = "100.100.45.7";
          };
          ipv6 = {
            public = "2a01:e34:ec2a:8e60:c4f0:fbff:fe8c:d6da";
            vpn = "fd7a:115c:a1e0::7";
          };
        };
      };
    });
}
