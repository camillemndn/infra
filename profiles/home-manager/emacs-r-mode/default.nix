{
  config,
  lib,
  ...
}:

{
  options.programs.emacs.RMode.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable R support in Emacs via ESS";
  };

  config = lib.mkIf config.programs.emacs.RMode.enable {
    programs.emacs.extraPackages = epkgs: with epkgs; [ ess ];
  };
}
