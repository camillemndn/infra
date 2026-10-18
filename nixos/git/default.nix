{
  config,
  lib,
  pkgs,
  ...
}:

let
  email = "camillemondon@free.fr";
  keys = config.users.users.camille.openssh.authorizedKeys.keys;

  # Commits signed by any of camille's keys are camille's, for git and for comin.
  allowedSigners = pkgs.writeText "allowed_signers" (
    lib.concatMapStrings (
      key:
      "${email} namespaces=\"git\" ${lib.concatStringsSep " " (lib.take 2 (lib.splitString " " key))}\n"
    ) keys
  );
in

{
  programs.git = {
    enable = true;

    config = {
      user = {
        name = "Camille M.";
        inherit email;
      };

      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "${allowedSigners}";
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
