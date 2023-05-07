{ config, lib, pkgs, ... }:

with lib;

{
  programs.tmux = {
    enable = true;
    terminal = "xterm-kitty";
    extraConfig = builtins.readFile ./tmux.conf;
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      yank
      sensible
      pain-control
      resurrect
      prefix-highlight
    ];
  };
}
