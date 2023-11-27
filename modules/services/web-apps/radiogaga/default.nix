{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.radiogaga;
in
{
  options = {
    services.radiogaga = {
      enable = mkEnableOption "radiogaga";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/radiogaga";
        description = "The directory where radiogaga stores its data files.";
      };

      authFile = mkOption {
        type = types.str;
        description = "The directory where radiogaga stores its data files.";
      };

      user = mkOption {
        type = types.str;
        default = "radiogaga";
        description = "User account under which radiogaga runs.";
      };

      group = mkOption {
        type = types.str;
        default = "radiogaga";
        description = "Group under which radiogaga runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.radiogaga = {
      description = "radiogaga";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.BASE_DIR = "${cfg.dataDir}";
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.radiogaga}/bin/radiogaga";
        CacheDirectory = "radiogaga";
        StateDirectory = "radiogaga";
        SupplementaryGroups = [ "audio" "pipewire" ];
        WorkingDirectory = "${pkgs.radiogaga}/share/radiogaga";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "radiogaga") {
      radiogaga = {
        inherit (cfg) group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
    users.groups.radiogaga = { };
  };
}
