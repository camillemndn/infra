{ pkgs, stdenv, writeText }:

let
  generic = builtins.readFile ./vimrc/general.vim;
  colors = builtins.readFile ./vimrc/colors.vim;
  indents = builtins.readFile ./vimrc/indents.vim;
  keybinds = builtins.readFile ./vimrc/keybinds.vim;
  linenumbers = builtins.readFile ./vimrc/linenumbers.vim;
  folding = builtins.readFile ./vimrc/folding.vim;

  plug = import ./vimrc/pluginconfigurations.nix;

in

''
  ${generic}
  ${colors}
  ${indents}
  ${keybinds}
  ${linenumbers}
  ${folding}

  ${plug}

''
