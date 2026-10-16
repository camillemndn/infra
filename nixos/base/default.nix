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
        user.name = "Camille M.";
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

    direnv.enable = true;

    neovim.enable = lib.mkDefault (!config.programs.nixvim.enable);

    command-not-found.enable = false;

    nix-index = lib.mkDefault {
      enable = true;
      package = pkgs.nix-index-with-db;
    };
  };

  services = {
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
      settings.Resolve = {
        DNSOverTLS = "opportunistic";
        DNSSEC = "allow-downgrade";
      };
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
      dust
      fastfetch
      htop
      lazygit
      lsof
      nh
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
  home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:

      let
        gtkConfig = {
          gtk-decoration-layout = "icon:minimize,maximize,close";
        };
      in

      {
        gtk = {
          gtk3.extraConfig = gtkConfig;
          gtk4 = {
            theme = null;
            extraConfig = gtkConfig;
          };
        };

        home = {
          keyboard.layout = "fr";
          language.base = "fr_FR.UTF-8";
          packages = [ pkgs.comma-with-db ];
          sessionVariables = {
            # GDK_BACKEND must NOT be forced here: xdg-desktop-portal-gnome
            # refuses to expose ScreenCast / Screenshot when GDK_BACKEND is
            # set ("Non-compatible display server, exposing settings only").
            # Modern GTK picks wayland automatically when XDG_SESSION_TYPE=wayland.
            QT_QPA_PLATFORM = "wayland";
          };
          stateVersion = lib.mkDefault "24.05";
        };

        programs = {
          fish.enable = true;
          home-manager.enable = true;

          nix-index = {
            enable = lib.mkDefault true;
            package = lib.mkDefault pkgs.nix-index-with-db;
          };
        };

        services.random-background = {
          enable = true;
          imageDirectory =
            (builtins.fetchGit {
              url = "https://github.com/orangci/walls-catppuccin-mocha/";
              rev = "7bfdf10d16ad3a689f9f0cf3a0930da3d1a245a8";
            }).outPath;
        };
      }
    )
  ];
}
