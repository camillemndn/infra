{
  home-manager.sharedModules = [
    (
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
    )
    (
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
    )
    (
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
            nixfmt
          ];
          programs.emacs.extraPackages = epkgs: with epkgs; [ nix-mode ];
        };
      }
    )
    (
      {
        config,
        lib,
        ...
      }:

      {
        options.programs.emacs.orgMode.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Org notebooks with Python in Emacs";
        };
        config = lib.mkIf config.programs.emacs.orgMode.enable {
          # envrc: per-buffer direnv environment.
          programs.emacs.extraPackages = epkgs: with epkgs; [ envrc ];
        };
      }
    )
    (
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
        };
      }
    )
    (
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
    )
  ];
}
