{
  config,
  lib,
  ...
}:

lib.mkIf config.programs.emacs.enable {
  programs.emacs = {
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
