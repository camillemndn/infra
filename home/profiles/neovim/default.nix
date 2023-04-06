{ pkgs, home, lib, config, ... }:

let
  cfg = config.profiles.neovim;
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
    enable = mkEnableOption "activate neovim program";
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
          coc.preferences.formatOnSaveFiletypes = [ "r" "ccls" "nix" "rust" "sql" "python" ];

          languageserver =
            {
              R = {
                command = "${pkgs.rWrapper.override{ packages = with pkgs.rPackages; [ languageserver ]; }}/bin/R";
                args = [ "--slave" "-e" "languageserver::run()" ];
                filetypes = [ "r" ];
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
              python = {
                command = "pyright";
                filetypes = [ "py" "python" ];
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
        #theme
        catppuccin
        # LSP
        nvim-lspconfig

        plenary-nvim

        #Telescope
        telescope-nvim

        nvim-web-devicons

        pkgs.unstable.vimPlugins.bufferline-nvim
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
        coc-pyright
        rust-vim
      ];

      extraPackages = with pkgs; [ rust-analyzer nil nixpkgs-fmt ccls ];

      extraConfig = ''
        luafile ${./settings.lua}
      '';
    };
  };
}
