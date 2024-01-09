{ config, lib, ... }:

let
  sshPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmuMNGkWQ7ozpC2UU0+jqMsRw1zVgT2Q9ORmLcTXpK2 camille@zeppelin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f camille@genesis"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWvUwCcmmjEFfE2cNE14w/ZPm9odzVUrKwTNAOR+UZR camille@thelonious"
  ];
in

{
  users.users.camille = {
    isNormalUser = true;
    description = "Camille";
    extraGroups = [
      "audio"
      "media"
      "networkmanager"
      "pipewire"
      "wheel"
    ];
    hashedPasswordFile = lib.mkDefault "/run/secrets-for-users/camille";
    openssh.authorizedKeys.keys = sshPubKeys;
  };

  users.users.root = {
    extraGroups = [ "audio" "pulse-access" ];
    openssh.authorizedKeys.keys = sshPubKeys;
  };

  sops.secrets.camille = {
    format = "binary";
    sopsFile = ./password;
    neededForUsers = true;
  };

  sops.age.keyFile = lib.mkIf (!config.services.openssh.enable && config.sops.secrets != { }) "/home/camille/.config/sops/age/keys.txt";


  programs.git = {
    enable = true;
    config = {
      user.name = "Camille M. (${config.networking.hostName})";
      user.email = "camillemondon@free.fr";
      pull.rebase = true;
      fetch.prune = true;
      diff.colorMoved = true;
    };
  };

  security.acme = {
    defaults.email = "camillemondon@free.fr";
    acceptTerms = true;
  };
}
