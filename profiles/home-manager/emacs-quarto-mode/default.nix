{
  config,
  lib,
  ...
}:

{
  options.programs.emacs.quartoMode.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Quarto support in Emacs";
  };

  config = lib.mkIf config.programs.emacs.quartoMode.enable {
    programs.emacs.extraPackages = epkgs: with epkgs; [ quarto-mode ];

    programs.emacs.extraConfig = ''
      (use-package quarto-mode
        init
        (setq markdown-enable-math t)
        :mode (("\\.Rmd" . poly-quarto-mode)))
    '';
  };
}
