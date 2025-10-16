{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.emacs.enable {
  programs.emacs = {
    package = pkgs.emacs-nox;

    extraPackages =
      epkgs: with epkgs; [
        catppuccin-theme
        company
        lsp-mode
        projectile
        use-package
      ];

    extraConfig = ''
      ;; Theme
      (load-theme 'catppuccin :no-confirm)

      ;; Disable auto-save #filename# files
      (setq auto-save-default nil)

      ;; Projectile
      (use-package projectile
        :init
        (projectile-mode +1)
        :bind (:map projectile-mode-map
                    ("C-c p" . projectile-command-map)))

      ;; Company mode
      (add-hook 'after-init-hook 'global-company-mode)

      ;; LSP mode
      (use-package lsp-mode
        :init
        (setq lsp-keymap-prefix "C-c l")
        (setq lsp-format-buffer-on-save t)
        :hook (lsp-mode . lsp-enable-which-key-integration)
        :commands lsp)
    '';
  };
}
