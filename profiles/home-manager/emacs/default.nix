{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.emacs.enable {
  programs.emacs = {
    package = pkgs.emacs29-nox;
    extraPackages =
      e: with e; [
        quarto-mode
        catppuccin-theme
      ];
    extraConfig = ''
      (load-theme 'catppuccin :no-confirm)
    '';
  };
}
