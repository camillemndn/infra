{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;
  cfg = config.services.librespot;

in
{
  options.services.librespot = {
    enable = lib.mkEnableOption "Librespot (Spotify Connect speaker daemon)";

    args = lib.mkOption {
      description = "CLI arguments generated from services.librespot.settings";
      internal = true;
      type = types.listOf types.str;
    };

    package = lib.mkPackageOption pkgs "librespot" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Command-line arguments to pass to librespot.

        Boolean values render as a flag if true, and nothing if false.
        Null values are ignored.
        All other values are rendered as options with an argument.
      '';

      type = types.submodule {
        options = {
          cache = lib.mkOption {
            default = "/var/cache/librespot";
            description = "Directory where audio files are cached.";
            type = types.nullOr types.path;
          };

          system-cache = lib.mkOption {
            default = "/var/lib/librespot";
            description = "Directory where credentials and volume data are stored.";
            type = types.nullOr types.path;
          };
        };

        freeformType =
          let
            t = types;
          in
          t.attrsOf (
            t.nullOr (
              t.oneOf [
                t.bool
                t.str
                t.int
                t.path
              ]
            )
          );
      };
    };

    user = lib.mkOption {
      default = "librespot";
      description = "User under which librespot runs.";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.librespot.args = lib.concatLists (
      lib.mapAttrsToList (
        k: v:
        if builtins.isNull v || (builtins.isBool v && !v) then
          [ ]
        else if (builtins.isBool v && v) then
          [ "--${k}" ]
        else
          [ "--${k}=${toString v}" ]
      ) cfg.settings
    );

    systemd.services.librespot = {
      after = [
        "network-online.target"
        "avahi-daemon.service"
      ];

      description = "Librespot (Spotify Connect receiver)";

      serviceConfig = {
        CacheDirectory = "librespot";

        ExecStart = pkgs.writeShellScript "librespot" ''
          exec '${cfg.package}/bin/librespot' ${lib.escapeShellArgs cfg.args}
        '';

        Group = "audio";
        Restart = "always";
        RestartSec = 12;
        StateDirectory = "librespot";
        SupplementaryGroups = [ "pipewire" ];
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.users.${cfg.user} = {
      createHome = true;
      description = "Librespot system user";
      group = "audio";
      home = "/var/lib/librespot";
      isSystemUser = true;
    };
  };
}
