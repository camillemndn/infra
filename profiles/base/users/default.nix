{ config, pkgs, lib, ... }:

with lib;

{
  imports = [ ./camille ];

  console.keyMap = "fr";

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

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.fish;
  };

  programs = {
    fish = {
      enable = true;
      promptInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      '';
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withRuby = false;
    };

    nix-index-database.comma.enable = true;
  };

  services = {
    eternal-terminal.enable = true;

    openssh.settings.PasswordAuthentication = false;

    mysql = {
      package = mkForce pkgs.mariadb;
      settings = {
        mysql.pager = "${pkgs.less}/bin/less -SFX";
        mysqld.init-connect = "'SET NAMES utf8mb4'";
      };
    };

    resolved.enable = true;
  };

  networking = {
    firewall.checkReversePath = mkIf config.services.tailscale.enable "loose";
    nftables.enable = true;
  };

  environment.systemPackages = with pkgs; [
    age
    comma
    deploy-rs
    dig
    direnv
    du-dust
    htop
    lazygit
    lsof
    neofetch
    nix-init
    nix-tree
    nixos-option
    nmap
    ntfs3g
    oh-my-fish
    powertop
    sops
    tldr
    unzip
    wget
    zip
  ];

  security.pki.certificateFiles = [ ./saumonnet.crt ];
}
