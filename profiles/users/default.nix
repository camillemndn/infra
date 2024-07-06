{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

{
  deployment.buildOnTarget = mkDefault true;

  console.keyMap = "fr";

  time.timeZone = mkDefault "Europe/Paris";

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
    mutableUsers = mkDefault false;
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

    command-not-found.enable = false;
    nix-index = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.nix-index-with-db;
    };
  };

  services = {
    eternal-terminal.enable = true;

    openssh.settings.PasswordAuthentication = mkDefault false;

    mysql = {
      package = mkForce pkgs.mariadb;
      settings = {
        mysql.pager = "${pkgs.less}/bin/less -SFX";
        mysqld.init-connect = "'SET NAMES utf8mb4'";
      };
    };

    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      dnsovertls = "opportunistic";
    };
  };

  networking = {
    firewall.checkReversePath = mkIf config.services.tailscale.enable "loose";
    nftables.enable = true;
  };

  environment.systemPackages = with pkgs; [
    attic-client
    dig
    direnv
    du-dust
    htop
    lazygit
    lsof
    neofetch
    nix-init
    nix-tree
    nix-update
    nixos-option
    nmap
    ntfs3g
    oh-my-fish
    powertop
    tldr
    unzip
    wget
    zip
    nix-output-monitor
    comma-with-db
  ];

  security.pki.certificateFiles = [ ./saumonnet.crt ];
}
