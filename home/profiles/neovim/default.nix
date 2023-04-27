{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.neovim;

  nvim-r = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-r";
    src = pkgs.fetchgit {
      url = "https://github.com/jalvesaq/nvim-r";
      rev = "f34eebfab6692483f2ee721abdb3d757be79fc7e";
      sha256 = "sha256-h2f7xyhMGfI7xR1KolyP/NcFDVjTyAaz2z0ZUTJgAdM=";
    };
    buildInputs = with pkgs; [ which vim zip ];
  };

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
in
with lib;

{
  options.profiles.neovim = {
    enable = mkEnableOption "Activate neovim program";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ nixfmt git nodejs ripgrep gcc ];

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
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
          ];

          python.linting.flake8Enabled = true;

          languageserver =
            {
              r = let r-lsp = pkgs.rWrapper.override { packages = with pkgs.rPackages; [ languageserver ]; }; in {
                command = "${r-lsp}/bin/R";
                args = [ "-s" "-e" "languageserver::run()" ];
                filetypes = [ "r" "rmd" ];
              };

              python = {
                command = "pyright";
                filetypes = [ "py" ];
              };

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
            };
        };
      };

      withPython3 = true;

      plugins = with pkgs.vimPlugins; [
        # Theme
        catppuccin

        # LSP
        nvim-lspconfig
        coc-pyright
        rust-vim

        plenary-nvim

        # Telescope
        telescope-nvim

        nvim-web-devicons

        bufferline-nvim
        nvim-colorizer-lua
        pears-nvim
        nvim-tree-lua

        (nvim-treesitter.withPlugins (ps: with ps; [
          tree-sitter-nix
          tree-sitter-python
        ]))

        vim-lastplace
        vim-nix
        vim-nixhash
        vim-yaml
        vim-toml
        vim-airline
        vim-devicons
        zig-vim
        vim-scriptease
        semshi
        coc-prettier

        nvim-r
      ];

      extraPackages = with pkgs; [
        ccls
        nil
        nixpkgs-fmt
        pyright
        python3.pkgs.autopep8
        python3.pkgs.flake8
      ];

      extraConfig = ''
        luafile ${./settings.lua}
      '';
    };
  };
}
