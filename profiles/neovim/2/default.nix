{ config, lib, pkgs, ... }:

let
  sources = import ./sources.nix;
  cfg = config.profiles.neovim-2;
in
with lib;

{

  options.profiles.neovim-2 = {
    enable = mkEnableOption "Activate my neovim 2";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (import ./vim.nix)
    ];

    programs.neovim = {
      enable = true;
      # package = pkgs.neovim-nightly;

      configure.packages.neovim-nightly = with pkgs; {
        start = [
          customVim.vim-cue
          customVim.vim-fish
          customVim.vim-fugitive
          customVim.vim-glsl
          customVim.vim-misc
          customVim.vim-pgsql
          customVim.vim-tla
          customVim.vim-zig
          customVim.pigeon
          customVim.AfterColors

          customVim.vim-nord
          customVim.nvim-comment
          customVim.nvim-lspconfig
          customVim.nvim-plenary # required for telescope
          customVim.nvim-telescope
          customVim.nvim-treesitter
          customVim.nvim-treesitter-playground
          customVim.nvim-treesitter-textobjects

          vimPlugins.vim-airline
          vimPlugins.vim-airline-themes
          vimPlugins.vim-eunuch
          vimPlugins.vim-gitgutter

          vimPlugins.vim-markdown
          vimPlugins.vim-nix
          vimPlugins.typescript-vim
        ];
      };

      configure.customRC = (import ./vim-config.nix) { inherit sources; };
    };
  };
}
