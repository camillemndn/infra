{
  inputs = {
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    buildbot-nix = {
      url = "github:camillemndn/buildbot-nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena/main";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns = {
      url = "github:kirelagin/dns.nix/master";
      flake = false;
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
    };

    nix-index-database = {
      url = "github:mic92/nix-index-database/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Yeshey/nix-minecraft/master";
      flake = false;
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };

    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stateless-uptime-kuma = {
      url = "git+https://git.dgnum.eu/DGNum/stateless-uptime-kuma.git?ref=master";
      flake = false;
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      flake = false;
    };

    uptime-kuma-api = {
      url = "git+https://git.dgnum.eu/Luj/uptime-kuma-api.git?ref=master";
      flake = false;
    };
  };

  outputs =
    inputs:
    import ./outputs.nix (
      import ./inputs.nix (
        builtins.removeAttrs inputs [
          "self"
        ]
      )
    );
}
