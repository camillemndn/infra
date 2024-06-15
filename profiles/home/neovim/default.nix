{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.neovim;
in
with lib;

{
  options.profiles.neovim = {
    enable = mkEnableOption "Activate neovim program";
    full.enable = mkEnableOption "Activate neovim program as IDE";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; if cfg.full.enable then [
      (python3.withPackages (p: with p; [ jupyter ipython plotly autopep8 flake8 ]))
      (quarto.override { extraRPackages = with rPackages; [ languageserver plotly ]; extraPythonPackages = p: with p; [ plotly ]; })
      (rWrapper.override { packages = with rPackages; [ rmarkdown languageserver plotly ]; })
    ] else [ python3 R ];

    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withPython3 = true;

      coc = mkIf cfg.full.enable {
        enable = true;
        settings = {
          coc.preferences.formatOnSaveFiletypes = [
            "ccls"
            "nix"
            "python"
            "r"
            "rmd"
            "latex"
            "lua"
          ];

          languageserver = {
            ccls = {
              command = "ccls";
              filetypes = [ "c" "cpp" "cuda" "objc" "objcpp" ];
              rootPatterns = [ ".ccls-root" "compile_commands.json" ];
              initializationOptions = {
                cache = {
                  directory = ".ccls-cache";
                };
                client = {
                  snippetSupport = true;
                };
              };
            };

            latex = {
              command = "texlab";
              filetypes = [ "tex" "bib" "plaintex" "context" ];
            };

            lua = {
              command = "lua-lsp";
              filetypes = [ "lua" ];
            };

            nix = {
              command = "nil";
              filetypes = [ "nix" ];
              rootPatterns = [ "flake.nix" ];
              settings = {
                nil = {
                  formatting = { command = [ "nixfmt" ]; };
                };
              };
            };

            python = {
              command = "pyright";
              filetypes = [ "py" ];
            };

            r = let r-lsp = pkgs.rWrapper.override { packages = with pkgs.rPackages; [ languageserver ]; }; in {
              command = "${r-lsp}/bin/R";
              args = [ "-s" "-e" "languageserver::run()" ];
              filetypes = [ "r" "rmd" ];
            };
          };

          python.linting.flake8Enabled = true;
        };
      };

      plugins =
        let
          nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (ps: with ps; [
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
          ]);
        in
        with pkgs.vimPlugins; mkIf cfg.full.enable [
          bufferline-nvim
          catppuccin-nvim
          cmp-nvim-lsp
          coc-prettier
          coc-pyright
          coc-texlab
          lspkind-nvim
          luasnip
          mason-nvim
          mason-lspconfig-nvim
          nvim-cmp
          nvim-colorizer-lua
          nvim-lspconfig
          Nvim-R
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

      extraPackages = with pkgs; mkIf cfg.full.enable [
        ccls
        fd
        lua.pkgs.lua-lsp
        lua.pkgs.luarocks-nix
        lua-language-server
        marksman
        nil
        nixfmt-rfc-style
        pyright
        ripgrep
        texlab
        texliveFull
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
