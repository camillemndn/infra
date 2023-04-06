{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./camille.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  users.mutableUsers = false;

  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;
  programs.fish.promptInit = ''
    ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    ${pkgs.direnv}/bin/direnv hook fish | source  
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
  ];

  services.mysql = {
    package = mkForce pkgs.mariadb;
    settings.mysql.pager = "${pkgs.less}/bin/less -SFX";
  };

  sops.defaultSopsFile = ../../secrets/passwords.yaml;

  home-manager.useGlobalPkgs = true;

  security.pki.certificateFiles = [ ./saumonnet.crt ];
}
