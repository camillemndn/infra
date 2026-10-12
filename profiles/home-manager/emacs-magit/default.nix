{
  config,
  lib,
  ...
}:

{
  options.programs.emacs.magit.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Git support in Emacs via Magit and diff-hl";
  };

  config = lib.mkIf config.programs.emacs.magit.enable {
    programs.emacs.extraPackages =
      epkgs: with epkgs; [
        diff-hl
        magit
      ];
  };
}
