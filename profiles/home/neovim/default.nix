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
    home.packages = with pkgs; [
      (quarto.override { extraRPackages = [ rPackages.plotly ]; extraPythonPackages = ps: with ps; [ plotly ]; })
      R
      rPackages.languageserver
    ];

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
                  formatting = { command = [ "nixpkgs-fmt" ]; };
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
          catppuccin = pkgs.vimUtils.buildVimPlugin {
            pname = "catppuccin";
            version = "0.2.9";
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "nvim";
              rev = "e1fc2c3ade0d8872665d7570c493bbd5e11919c7";
              sha256 = "sha256-s8nMeBtDnf/L7/rYwmf6UexykfADXJx0fZoDg8JacGs=";
            };
          };

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

          otter-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "otter-nvim";
            src = pkgs.fetchgit {
              url = "https://github.com/jmbuhr/otter.nvim";
              rev = "v0.16.1";
              sha256 = "sha256-QY1RimrDzoY2xbKv/3m89IsEd0NUbJNlGIW4vxPnQZo=";
            };
          };

          quarto-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "quarto-nvim";
            src = pkgs.fetchgit {
              url = "https://github.com/quarto-dev/quarto-nvim";
              rev = "v0.13.1";
              sha256 = "sha256-aEJyhd+bBXsvyDDQT2W/ZtpJB4W+aeUszp8h0fzQnBs=";
            };
          };
        in
        with pkgs.vimPlugins; mkIf cfg.full.enable [
          bufferline-nvim
          catppuccin
          cmp-nvim-lsp
          coc-prettier
          coc-pyright
          coc-texlab
          lspkind-nvim
          luasnip
          nvim-cmp
          nvim-colorizer-lua
          nvim-lspconfig
          nvim-treesitter
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
        R
        ccls
        fd
        lua.pkgs.lua-lsp
        lua.pkgs.luarocks-nix
        marksman
        nil
        nixpkgs-fmt
        pyright
        python3.pkgs.autopep8
        python3.pkgs.flake8
        (quarto.override { extraRPackages = [ rPackages.plotly ]; extraPythonPackages = ps: with ps; [ plotly ]; })
        ripgrep
        texlab
        texlive.combined.scheme-full
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
