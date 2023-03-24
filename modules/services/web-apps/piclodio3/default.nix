{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.piclodio3;
in
{
  options = {
    services.piclodio3 = {
      enable = mkEnableOption (lib.mdDoc "piclodio3");

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/piclodio3";
        description = lib.mdDoc "The directory where piclodio3 stores its data files.";
      };

      authFile = mkOption {
        type = types.str;
        description = lib.mdDoc "The directory where piclodio3 stores its data files.";
      };

      user = mkOption {
        type = types.str;
        default = "piclodio3";
        description = lib.mdDoc "User account under which piclodio3 runs.";
      };

      group = mkOption {
        type = types.str;
        default = "piclodio3";
        description = lib.mdDoc "Group under which piclodio3 runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.piclodio3 = {
      description = "piclodio3";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.BASE_DIR = "${cfg.dataDir}";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.piclodio3}/bin/piclodio3";
        CacheDirectory = "piclodio3";
        StateDirectory = "piclodio3";
        SupplementaryGroups = [ "audio" "pipewire" ];
        WorkingDirectory = "${pkgs.piclodio3}/share/piclodio3";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "piclodio3") {
      piclodio3 = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
    users.groups.piclodio3 = { };
  };
}
