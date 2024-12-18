let
  inputs = import ./deps;
  pkgs = import inputs.nixpkgs-unstable { };
  agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
  nixos-anywhere = import scripts/nixos-anywhere.nix;
  pre-commit-hook = (import inputs.git-hooks).run {
    src = ./.;

    hooks = {
      statix.enable = true;
      deadnix.enable = true;
      rfc101 = {
        enable = true;
        name = "RFC-101 formatting";
        entry = "${pkgs.lib.getExe pkgs.nixfmt-rfc-style}";
        files = "\\.nix$";
      };
      commitizen.enable = true;
    };
  };

  nix-update-all = pkgs.callPackage (
    {
      lib,
      writeShellScriptBin,
      nix-update,
    }:
    writeShellScriptBin "nix-update-all" (
      lib.concatMapStringsSep "\n" (pkg: "${nix-update}/bin/nix-update -f release.nix ${pkg}") (
        lib.attrNames (import ./.).packages.x86_64-linux
      )
    )
  ) { };

in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    agenix
    colmena
    nix-update-all
    nixos-anywhere
    npins
    statix
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
  '';
}
