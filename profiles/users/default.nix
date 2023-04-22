{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./camille.nix
  ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LANG = "fr_FR.UTF-8";
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_ALL = "fr_FR.UTF-8";
    LC_CTYPE = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MESSAGES = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console.keyMap = "fr";

  users.mutableUsers = false;

  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
  programs.fish.promptInit = ''
    ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
  '';

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withRuby = false;
  };

  services.eternal-terminal.enable = true;

  networking.firewall.checkReversePath = mkIf config.services.tailscale.enable "loose";

  environment.systemPackages = with pkgs; [
    htop
    powertop
    lsof
    neofetch
    du-dust
    wget
    zip
    unzip
    ntfs3g
    oh-my-fish
    age
    sops
    unstable.deploy-rs
    unstable.nixos-option
    unstable.nix-tree
    nix-init
    direnv
    tldr
  ];

  services.mysql = {
    package = mkForce pkgs.mariadb;
    settings.mysql.pager = "${pkgs.less}/bin/less -SFX";
  };

  sops.defaultSopsFile = ../../secrets/passwords.yaml;

  home-manager.useGlobalPkgs = true;

  security.pki.certificateFiles = [ ./saumonnet.crt ];
}
