{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.yarr;
in
{
  options = {
    services.yarr = {
      enable = mkEnableOption (lib.mdDoc "yarr!");

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/yarr";
        description = lib.mdDoc "The directory where yarr stores its data files.";
      };

      authFile = mkOption {
        type = types.str;
        description = lib.mdDoc "The directory where yarr stores its data files.";
      };

      user = mkOption {
        type = types.str;
        default = "yarr";
        description = lib.mdDoc "User account under which yarr runs.";
      };

      group = mkOption {
        type = types.str;
        default = "yarr";
        description = lib.mdDoc "Group under which yarr runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.yarr = {
      description = "yarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.yarr}/bin/yarr -db ${cfg.dataDir}/yarr.db -auth-file ${cfg.authFile}";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "yarr") {
      yarr = {
        inherit (cfg) group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
    users.groups.yarr = { };
  };
}
