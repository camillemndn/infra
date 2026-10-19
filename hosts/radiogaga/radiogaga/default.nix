{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.radiogaga;
in
{
  options = {
    services.radiogaga = {
      enable = mkEnableOption "radiogaga";

      authFile = mkOption {
        description = "The directory where radiogaga stores its data files.";
        type = types.str;
      };

      dataDir = mkOption {
        default = "/var/lib/radiogaga";
        description = "The directory where radiogaga stores its data files.";
        type = types.str;
      };

      group = mkOption {
        default = "radiogaga";
        description = "Group under which radiogaga runs.";
        type = types.str;
      };

      user = mkOption {
        default = "radiogaga";
        description = "User account under which radiogaga runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts.radiogaga = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 4200;
        }
      ];

      locations = {
        "/".tryFiles = "$uri $uri/ /index.html =404";
        "/api".proxyPass = "http://127.0.0.1:8000";
      };

      root = "${pkgs.radiogaga}/share";
    };

    systemd = {
      services.radiogaga = {
        after = [
          "network.target"
          "pipewire.service"
        ];

        description = "radiogaga";
        environment.BASE_DIR = "${cfg.dataDir}";

        serviceConfig = {
          CacheDirectory = "radiogaga";
          ExecStart = "${pkgs.radiogaga}/bin/radiogaga";
          Group = cfg.group;
          Restart = "on-failure";
          StateDirectory = "radiogaga";

          SupplementaryGroups = [
            "audio"
            "pipewire"
          ];

          Type = "simple";
          User = cfg.user;
          WorkingDirectory = "${pkgs.radiogaga}/share";
        };

        wantedBy = [ "multi-user.target" ];
      };

      tmpfiles.rules = [ "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -" ];
    };

    users = {
      groups.radiogaga = { };

      users = mkIf (cfg.user == "radiogaga") {
        radiogaga = {
          inherit (cfg) group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };
}
