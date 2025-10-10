{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.neovim;
in
with lib;

{
  options.programs.neovim.full.enable = mkEnableOption "Activate neovim program as IDE";

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      if cfg.full.enable then
        [
          (python3.withPackages (
            p: with p; [
              jupyter
              ipython
              plotly
              autopep8
              flake8
            ]
          ))
          (quarto.override {
            extraRPackages = with rPackages; [
              languageserver
              plotly
            ];
            extraPythonPackages = p: with p; [ plotly ];
          })
          (rWrapper.override {
            packages = with rPackages; [
              rmarkdown
              languageserver
              plotly
            ];
          })
        ]
      else
        [ ];

    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withPython3 = true;

      coc = mkIf cfg.full.enable {
        enable = true;
        settings = {
          coc.preferences.formatOnSaveFiletypes = [
            "bash"
            "ccls"
            "css"
            "haskell"
            "html"
            "javascript"
            "latex"
            "lua"
            "markdown"
            "nix"
            "python"
            "r"
            "rmd"
            "rust"
          ];

          languageserver = {
            bash = {
              command = "bash-language-server";
              args = [ "start" ];
              filetypes = [ "sh" ];
            };

            ccls = {
              command = "ccls";
              filetypes = [
                "c"
                "cpp"
                "cuda"
                "objc"
                "objcpp"
              ];
              rootPatterns = [
                ".ccls-root"
                "compile_commands.json"
              ];
              initializationOptions = {
                cache = {
                  directory = ".ccls-cache";
                };
                client = {
                  snippetSupport = true;
                };
              };
            };

            haskell = {
              command = "haskell-language-server-wrapper";
              args = [ "--lsp" ];
              rootPatterns = [
                "*.cabal"
                "stack.yaml"
                "cabal.project"
                "package.yaml"
                "hie.yaml"
              ];
              filetypes = [
                "haskell"
                "lhaskell"
              ];
              settings.haskell = {
                checkParents = "CheckOnSave";
                checkProject = true;
                maxCompletions = 40;
                formattingProvider = "ormolu";
                plugin = {
                  stan = {
                    globalOn = true;
                  };
                };
              };
            };

            latex = {
              command = "texlab";
              filetypes = [
                "tex"
                "bib"
                "plaintex"
                "context"
              ];
            };

            lua = {
              command = "lua-lsp";
              filetypes = [ "lua" ];
            };

            nix = {
              command = "nil";
              filetypes = [ "nix" ];
              rootPatterns = [ "flake.nix" ];
              settings.nil = {
                formatting = {
                  command = [ "nixfmt" ];
                };
              };
            };

            python = {
              command = "pyright";
              filetypes = [
                "py"
                "sage"
              ];
            };

            r =
              let
                r-lsp = pkgs.rWrapper.override { packages = with pkgs.rPackages; [ languageserver ]; };
              in
              {
                command = "${r-lsp}/bin/R";
                args = [
                  "-s"
                  "-e"
                  "languageserver::run()"
                ];
                filetypes = [
                  "r"
                  "rmd"
                ];
              };
          };

          python.linting.flake8Enabled = true;

          rust-analyzer = {
            enable = true;
            cargo.allFeatures = true;
            checkOnSave.allTargets = true;
          };
        };
      };

      plugins =
        let
          nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
            ps: with ps; [
              tree-sitter-bash
              tree-sitter-css
              tree-sitter-html
              tree-sitter-julia
              tree-sitter-latex
              tree-sitter-lua
              tree-sitter-markdown
              tree-sitter-markdown-inline
              tree-sitter-nix
              tree-sitter-python
              tree-sitter-query
              tree-sitter-r
              tree-sitter-vim
              tree-sitter-vimdoc
              tree-sitter-yaml
            ]
          );
        in
        with pkgs.vimPlugins;
        mkIf cfg.full.enable [
          bufferline-nvim
          catppuccin-nvim
          cmp-nvim-lsp
          coc-prettier
          coc-pyright
          coc-rust-analyzer
          coc-texlab
          lspkind-nvim
          luasnip
          mason-nvim
          mason-lspconfig-nvim
          nvim-cmp
          nvim-colorizer-lua
          nvim-lilypond-suite
          nvim-lspconfig
          nvim-r
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-tree-lua
          nvim-web-devicons
          otter-nvim
          pears-nvim
          plenary-nvim
          quarto-nvim
          rust-vim
          semshi
          telescope-nvim
          vim-airline
          vim-devicons
          vim-lastplace
          vim-nix
          vim-nixhash
          vim-scriptease
          vim-toml
          vim-yaml
          which-key-nvim
          zig-vim
        ];

      extraPackages =
        with pkgs;
        mkIf cfg.full.enable [
          ccls
          fd
          haskell-language-server
          lua-language-server
          lua.pkgs.lua-lsp
          lua.pkgs.luarocks-nix
          marksman
          nil
          unstable.nixfmt-rfc-style
          ormolu
          pyright
          ripgrep
          rust-analyzer
          rustfmt
          shfmt
          texlab
          texliveFull
          unstable.bash-language-server
          wl-clipboard
          wl-clipboard-x11
        ];

      extraConfig = ''
        luafile ${./settings.lua}
        ${optionalString cfg.full.enable "luafile ${./quarto.lua}"}
      '';
    };
  };
}
