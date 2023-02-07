{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.neovim;
in
with lib;

{
  options.profiles.neovim = {
    enable = mkEnableOption "Activate my neovim";
  };

  config = mkIf cfg.enable {
    environment.noXlibs = lib.mkForce false;

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withRuby = false;
      configure = (import ./customization.nix { pkgs = pkgs; });
    };

    environment.systemPackages = with pkgs; [
      tree-sitter
      nodejs
      deno
      ctags
      nodePackages.bash-language-server
      gcc
      ccls
      nodePackages.vscode-css-languageserver-bin
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.vscode-html-languageserver-bin
      nodePackages.vscode-json-languageserver-bin
      python310Packages.python-lsp-server
      nodePackages.yaml-language-server
      nodePackages.vim-language-server
      texlab
      rnix-lsp
      nodePackages.diagnostic-languageserver
      shellcheck
      #languagetool
      elixir_ls
      elmPackages.elm-language-server
      #java-language-server
    ];
  };
}
