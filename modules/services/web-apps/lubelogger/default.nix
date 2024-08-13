{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.lubelogger;
in
with lib;

{
  options.services.lubelogger = {
    enable = mkEnableOption "LubeLogger, Vehicle Maintenance and Fuel Mileage Tracker";

    settings = lib.mkOption {
      type = lib.types.submodule { freeformType = with lib.types; attrsOf str; };
      default = { };
      example = {
        LUBELOGGER_ALLOWED_FILE_EXTENSIONS = "";
        LUBELOGGER_LOGO_URL = "";
      };
      description = ''
        Additional configuration for LubeLogger, see
        <https://docs.lubelogger.com/Environment%20Variables>
        for supported values.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.lubelogger = {
      description = "LubeLogger";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = cfg.settings;
      serviceConfig = {
        Type = "simple";
        StateDirectory = "lubelogger";
        WorkingDirectory = "/var/lib/lubelogger";
        DynamicUser = true;
        ExecStart = "${pkgs.lubelogger}/bin/CarCareTracker";
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
  };
}
