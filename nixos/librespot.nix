{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;

  # Like lib.mapAttrsToList, but concatenate the results
  concatMapAttrsToList =
    f: attrs: builtins.concatMap (name: f name attrs.${name}) (builtins.attrNames attrs);

  cfg = config.services.librespot;

in
{
  options.services.librespot = {
    enable = lib.mkEnableOption "Librespot (Spotify Connect speaker daemon)";

    package = lib.mkPackageOption pkgs "librespot" { };

    settings = lib.mkOption {
      description = ''
        Command-line arguments to pass to librespot.

        Boolean values render as a flag if true, and nothing if false.
        Null values are ignored.
        All other values are rendered as options with an argument.
      '';
      type = types.submodule {
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

        options = {
          cache = lib.mkOption {
            default = "/var/cache/librespot";
            type = types.nullOr types.path;
            description = "Directory where audio files are cached.";
          };

          system-cache = lib.mkOption {
            default = "/var/lib/librespot";
            type = types.nullOr types.path;
            description = "Directory where credentials and volume data are stored.";
          };
        };
      };
      default = { };
    };

    args = lib.mkOption {
      type = types.listOf types.str;
      internal = true;
      description = "CLI arguments generated from services.librespot.settings";
    };

    user = lib.mkOption {
      type = types.str;
      default = "librespot";
      description = "User under which librespot runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      description = "Librespot system user";
      group = "audio";
      home = "/var/lib/librespot";
      createHome = true;
    };

    services.librespot.args = concatMapAttrsToList (
      k: v:
      if builtins.isNull v || (builtins.isBool v && !v) then
        [ ]
      else if (builtins.isBool v && v) then
        [ "--${k}" ]
      else
        [ "--${k}=${toString v}" ]
    ) cfg.settings;

    systemd.services.librespot = {
      description = "Librespot (Spotify Connect receiver)";
      after = [
        "network-online.target"
        "avahi-daemon.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = "audio";
        SupplementaryGroups = [ "pipewire" ];
        ExecStart = pkgs.writeShellScript "librespot" ''
          exec '${cfg.package}/bin/librespot' ${lib.escapeShellArgs cfg.args}
        '';

        Restart = "always";
        RestartSec = 12;
        StateDirectory = "librespot";
        CacheDirectory = "librespot";
      };
    };
  };
}
