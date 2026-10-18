{ config, lib, ... }:

let
  email = "camillemondon@free.fr";
  keys = config.users.users.camille.openssh.authorizedKeys.keys;

  # Trusted commit signers, for git and for comin: camille from any of their
  # machines, and the bot that opens the daily lon update.
  signers =
    map (key: {
      inherit email;
      key = lib.concatStringsSep " " (lib.take 2 (lib.splitString " " key));
    }) keys
    ++ [
      {
        email = "lon-bot@git.mndn.fr";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJma0AITkBgjbrIdrG8YGkB01Q/gtBqXxh/OMneofOy";
      }
    ];
in

{
  environment.etc."ssh/allowed_signers".text = lib.concatMapStrings (
    s: "${s.email} namespaces=\"git\" ${s.key}\n"
  ) signers;

  programs.git = {
    enable = true;

    config = {
      user = {
        name = "Camille M.";
        inherit email;
      };

      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "/etc/ssh/allowed_signers";
      };

      pull.rebase = true;
      fetch.prune = true;
      rebase.autoStash = true;
      push.autoSetupRemote = true;
      diff.colorMoved = true;
    };
  };

  # Only machines holding one of camille's keys sign.
  home-manager.users.camille =
    lib.mkIf (builtins.any (lib.hasSuffix " camille@${config.networking.hostName}") keys)
      (
        { config, ... }:

        {
          programs.git = {
            enable = true;

            signing = {
              format = "ssh";
              key = "${config.home.homeDirectory}/.ssh/id_ed25519";
              signByDefault = true;
            };
          };
        }
      );
}
