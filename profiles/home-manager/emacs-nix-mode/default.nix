{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.programs.emacs.nixMode.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Nix support in Emacs";
  };

  config = lib.mkIf config.programs.emacs.nixMode.enable {
    home.packages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];

    programs.emacs.extraPackages = epkgs: with epkgs; [ nix-mode ];
  };
}
