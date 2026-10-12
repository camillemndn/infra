{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.emacs.enable {
  # Searched by consult-ripgrep and consult-fd.
  home.packages = with pkgs; [
    fd
    ripgrep
  ];

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
