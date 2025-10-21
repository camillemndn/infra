{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.emacs.enable {
  programs.emacs = {
    package = pkgs.emacs-pgtk;

    extraPackages =
      epkgs: with epkgs; [
        consult
        corfu
        eglot
        orderless
        projectile
        use-package
        vertico
      ];
  };
}
