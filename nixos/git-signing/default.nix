{ config, lib, ... }:

let
  keys = config.users.users.camille.openssh.authorizedKeys.keys;
in

# Only machines holding one of camille's keys sign.
lib.mkIf (builtins.any (lib.hasSuffix " camille@${config.networking.hostName}") keys) {
  home-manager.users.camille =
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
    };
}
