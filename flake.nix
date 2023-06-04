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

      dnsRecords = with nixpkgs.lib;
        let
          machineInfo = {
            zeppelin = { vpn = "100.100.45.7"; public = "78.192.168.230"; };
            radiogaga = { vpn = "100.100.45.20"; };
            offspring = { public = "141.145.197.42"; };
          };

          splitSuffix = len: sep: string:
            let l = splitString sep string;
            in
            [ (concatStringsSep sep (drop (length l - len) l)) (concatStringsSep sep (take (length l - len) l)) ];

          isVPN = x: hasSuffix "luj" x || hasSuffix "kms" x || hasSuffix "saumon" x;

          extractDomain = x:
            if (isVPN x) then (splitSuffix 1 "." x) else
            splitSuffix 2 "." x;

          domainToRecord = machine: x:
            if (!(hasInfix "." x) || hasInfix ".local" x) then { } else
            let
              zone = head (extractDomain x);
              subdomain = last (extractDomain x);
            in
            {
              ${zone} = {
                TTL = 60 * 60;
                NS = [ "@" ];
                SOA = {
                  nameServer = "@";
                  adminEmail = "dns@saumon.network";
                  serial = 0;
                };
              } //
              (if (subdomain == "") then {
                A = with machineInfo.${machine};
                  (if isVPN x then [ vpn ] else [ public ]);
              } else {
                subdomains.${subdomain}.A = with machineInfo.${machine}; if isVPN x then [ vpn ] else [ public ];
              });
            };

          getDomains = machine: with self.nixosConfigurations.${machine}.config; attrNames services.nginx.virtualHosts ++ optional services.tailscale.enable "${machine}.kms";

          recursiveUpdateManyAttrs = foldl recursiveUpdate { };
        in
        recursiveUpdateManyAttrs (concatMap (machine: map (domainToRecord machine) (getDomains machine)) (attrNames machineInfo));
    });
}
