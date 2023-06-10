{ config, ... }:

let
  sshPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEWwoOi96UggNLakKekjf/FUL3F0CeG727OtvEpvOks camille@wutang"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICbr8wzBA6LS1dqTLHZSgpJN9NKZ/bv5ybxQSRePUtUs camille@rush"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmuMNGkWQ7ozpC2UU0+jqMsRw1zVgT2Q9ORmLcTXpK2 camille@zeppelin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+UXgmrVJa2+9nBFXRL1GEbJ940kpaydDQSpv7l46Ll camille@radiogaga"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f camille@genesis"
  ];
in

{
  users.users.camille = {
    isNormalUser = true;
    description = "Camille";
    extraGroups = [ "networkmanager" "wheel" "mediasrv" "audio" "pipewire" ]; # Enable ‘sudo’ for the user.
    passwordFile = "/run/secrets-for-users/camille";
    openssh.authorizedKeys.keys = sshPubKeys;
  };

  sops.secrets.camille = {
    format = "binary";
    sopsFile = ./password;
    neededForUsers = true;
  };

  sops.age.keyFile = "/home/camille/.config/sops/age/keys.txt";

  users.users.root = {
    extraGroups = [ "audio" "pulse-access" ];
    openssh.authorizedKeys.keys = sshPubKeys;
  };

  programs.git = {
    enable = true;
    config = {
      user.name = config.networking.hostName;
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
