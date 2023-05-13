{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.neovim;
in
with lib;

{
  options.profiles.neovim = {
    enable = mkEnableOption "Activate neovim program";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      coc = {
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

      withPython3 = true;

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

          # nvim-r = pkgs.vimUtils.buildVimPlugin {
          #   name = "nvim-r";
          #   src = pkgs.fetchgit {
          #     url = "https://github.com/jalvesaq/nvim-r";
          #     rev = "f34eebfab6692483f2ee721abdb3d757be79fc7e";
          #     sha256 = "sha256-h2f7xyhMGfI7xR1KolyP/NcFDVjTyAaz2z0ZUTJgAdM=";
          #   };
          #   buildInputs = with pkgs; [ which vim zip ];
          # };

          otter-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "otter-nvim";
            src = pkgs.fetchgit {
              url = "https://github.com/jmbuhr/otter.nvim";
              rev = "2f03fb749527c9b53b9b132a4a9819e6edfe5487";
              sha256 = "sha256-wRSuiaNIaNsB2MF3sjDYj3B5RJLy4xYghgpOZL3KTAc=";
            };
            # buildInputs = with pkgs; [ which vim zip ];
          };

          quarto-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "quarto-nvim";
            src = pkgs.fetchgit {
              url = "https://github.com/quarto-dev/quarto-nvim";
              rev = "f03913ae9ff2d4b26ba8bc20da2bfa04e232509e";
              sha256 = "sha256-MkoJORN7ad0Rb9mImyc8nmHWX4e73G4/AwGbGb/Qbck=";
            };
          };

          # quarto-nvim-kickstarter = pkgs.vimUtils.buildVimPlugin {
          #   name = "quarto-nvim-kickstarter";
          #   src = pkgs.fetchgit {
          #     url = "https://github.com/quarto-dev/quarto-nvim";
          #     rev = "5281051ded85a9dc41d72cd31af30a0cd9639216";
          #     sha256 = lib.fakeHash;
          #   };
          #   nativeBuildInputs = with pkgs; [ quarto-nvim git ];
          # };
        in
        with pkgs.vimPlugins; [
          bufferline-nvim
          catppuccin
          coc-prettier
          coc-pyright
          coc-texlab
          nvim-colorizer-lua
          nvim-cmp
          nvim-lspconfig
          # nvim-r
          (nvim-treesitter.withPlugins (ps: with ps; [
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
          ]))
          nvim-tree-lua
          nvim-web-devicons
          otter-nvim
          pears-nvim
          plenary-nvim
          quarto-nvim
          # quarto-nvim-kickstarter
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
          zig-vim
        ];

      extraPackages = with pkgs; [
        ccls
        lua.pkgs.lua-lsp
        lua.pkgs.luarocks-nix
        nil
        nixpkgs-fmt
        pyright
        (quarto.override { extraRPackages = [ rPackages.plotly ]; extraPythonPackages = ps: with ps; [ plotly ]; })
        R
        ripgrep
        texlab
        texlive.combined.scheme-full
        wl-clipboard
        wl-clipboard-x11
        pkgs.python3.pkgs.autopep8
        pkgs.python3.pkgs.flake8
      ];

      extraConfig = ''
        luafile ${./settings.lua}
      '';
    };
  };
}
