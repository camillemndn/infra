{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.sheetable;
in
with lib;

{
  options = {
    services.sheetable = {
      enable = mkEnableOption "SheetAble";

      user = mkOption {
        description = "The user under which SheetAble runs.";
        type = types.str;
        default = "sheetable";
      };

      group = mkOption {
        description = "The group under which SheetAble runs.";
        type = types.str;
        default = "sheetable";
      };

      settings = lib.mkOption {
        type = lib.types.submodule { freeformType = with lib.types; attrsOf str; };
        default = {
          API_SECRET = ""; # This can be any string you want with which your jwt key is going to be encrypted
          DB_DRIVER = "sqlite"; # mysql, postgres, sqlite
          ADMIN_EMAIL = "camille@mondon.me"; # Your admin email
          ADMIN_PASSWORD = "test"; # Your admin password
          PORT = "7777"; # Can be any port you want
          DEV = "0"; # 0, 1 - if 1: activated dev mode for developing purposes
          CONFIG_PATH = "/var/lib/sheetable"; # Path where you want your data to be instead of in the root dir
        };
        description = ''
          Additional configuration for SheetAble, see
          <https://sheetable.net/docs/configuration>
          for supported values.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.sheetable = {
      description = "SheetAble";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = cfg.settings;
      serviceConfig = {
        Type = "simple";
        StateDirectory = "sheetable";
        User = cfg.user;
        ExecStart = "${pkgs.sheetable}/bin/sheetable";
        Restart = "on-failure";
        ProtectHome = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        NoNewPrivileges = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
      };
    };

    users.users = optionalAttrs (cfg.user == "sheetable") {
      sheetable = {
        home = "/var/lib/sheetable";
        createHome = true;
        isSystemUser = true;
        inherit (cfg) group;
      };
    };

    users.groups = optionalAttrs (cfg.group == "sheetable") { sheetable = { }; };
  };
}
