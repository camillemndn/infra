let
  inputs = import ./lon.nix;
  pkgs = import inputs.nixpkgs-unstable { };
  agenix = pkgs.callPackage "${inputs.agenix}/pkgs/agenix.nix" { };
  nixos-anywhere = import scripts/nixos-anywhere.nix;
  pre-commit-hook = (import inputs.git-hooks).run {
    src = ./.;

    hooks = {
      statix.enable = true;
      rfc101 = {
        enable = true;
        name = "RFC-101 formatting";
        entry = "${pkgs.lib.getExe pkgs.nixfmt-rfc-style}";
        files = "\\.nix$";
      };
      commitizen.enable = true;
    };
  };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    agenix
    colmena
    lon
    nixos-anywhere
    statix
  ];
  shellHook = ''
    ${pre-commit-hook.shellHook}
    statix fix
  '';
}
