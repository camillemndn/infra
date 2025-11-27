{
  config,
  pkgs,
  lib,
  ...
}:

let
  sshPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmuMNGkWQ7ozpC2UU0+jqMsRw1zVgT2Q9ORmLcTXpK2 camille@zeppelin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f camille@genesis"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWvUwCcmmjEFfE2cNE14w/ZPm9odzVUrKwTNAOR+UZR camille@thelonious"
  ];
in

{
  users = {
    defaultUserShell = pkgs.fish;

    users = {
      camille = {
        isNormalUser = true;
        description = "Camille";
        extraGroups = [
          "audio"
          "lp"
          "media"
          "networkmanager"
          "pipewire"
          "scanner"
          "wheel"
        ];
        openssh.authorizedKeys.keys = sshPubKeys;
      };

      root = {
        extraGroups = [
          "audio"
          "pulse-access"
        ];
        openssh.authorizedKeys.keys = sshPubKeys;
      };
    };
  };

  deployment.buildOnTarget = lib.mkDefault true;

  programs = {
    git = {
      enable = true;
      config = {
        user.name = "Camille M. (${config.networking.hostName})";
        user.email = "camillemondon@free.fr";
        pull.rebase = true;
        fetch.prune = true;
        rebase.autoStash = true;
        push.autoSetupRemote = true;
        diff.colorMoved = true;
      };
    };

    fish = {
      enable = true;
      promptInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      '';
    };

    neovim.enable = lib.mkDefault (!config.programs.nixvim.enable);

    command-not-found.enable = false;

    nix-index = lib.mkDefault {
      enable = true;
      package = pkgs.nix-index-with-db;
    };
  };

  services = {
    eternal-terminal.enable = true;
    openssh.settings.PasswordAuthentication = lib.mkDefault false;

    mysql = {
      package = lib.mkForce pkgs.mariadb;
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
    firewall.checkReversePath = lib.mkIf config.services.tailscale.enable "loose";
    nftables.enable = true;
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      attic-client
      comma-with-db
      dig
      direnv
      dust
      htop
      lazygit
      lsof
      neofetch
      nix-init
      nix-output-monitor
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
    ];
  };

  security = {
    acme = {
      defaults.email = "camillemondon@free.fr";
      acceptTerms = true;
    };
    pki.certificateFiles = [ ./saumonnet.crt ];
  };
}
