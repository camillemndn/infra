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
  options = {
    services.lubelogger = {
      enable = mkEnableOption "Lubelogger, a self-hosted, open-source, web-based vehicle maintenance and fuel milage tracker";

      package = mkPackageOption pkgs "lubelogger" { };

      dataDir = mkOption {
        description = "Path to Lubelogger config and metadata.";
        default = "/var/lib/lubelogger";
        type = types.str;
      };

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

      port = mkOption {
        description = "The TCP port Lubelogger will listen on.";
        default = 5000;
        type = types.port;
      };

      user = mkOption {
        description = "User account under which Lubelogger runs.";
        default = "lubelogger";
        type = types.str;
      };

      group = mkOption {
        description = "Group under which Lubelogger runs.";
        default = "lubelogger";
        type = types.str;
      };

      openFirewall = mkOption {
        description = "Open ports in the firewall for the Lubelogger web interface.";
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    services.lubelogger.settings = {
      DOTNET_CONTENTROOT = cfg.dataDir;
      Kestrel__Endpoints__Http__Url = "http://localhost:${toString cfg.port}";
    };

    systemd.services.lubelogger = {
      description = "Lubelogger, a self-hosted, open-source, web-based vehicle maintenance and fuel milage tracker";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = cfg.settings;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = baseNameOf cfg.dataDir;
        WorkingDirectory = cfg.dataDir; # "${cfg.package}/lib/lubelogger";
        ExecStartPre = pkgs.writeShellScript "lubelogger-prestart" ''
          cd $STATE_DIRECTORY
          if [ ! -e .nixos-lubelogger-contentroot-copied ]; then
            cp -r ${cfg.package}/lib/lubelogger/* .
            chmod -R 744 .
            touch .nixos-lubelogger-contentroot-copied
          fi
        '';
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
        # BindPaths = [
        #   "${cfg.dataDir}/config:${cfg.package}/lib/lubelogger/config"
        #   "${cfg.dataDir}/data:${cfg.package}/lib/lubelogger/data"
        #   "${cfg.dataDir}/temp:${cfg.package}/lib/lubelogger/wwwroot/temp"
        #   "${cfg.dataDir}/images:${cfg.package}/lib/lubelogger/wwwroot/images"
        # ];
      };
    };

    # systemd.tmpfiles.rules = [
    #   "d '${cfg.dataDir}/config' 0770 '${cfg.user}' '${cfg.group}' - -"
    #   "d '${cfg.dataDir}/data' 0770 '${cfg.user}' '${cfg.group}' - -"
    #   "d '${cfg.dataDir}/temp' 0770 '${cfg.user}' '${cfg.group}' - -"
    #   "d '${cfg.dataDir}/images' 0770 '${cfg.user}' '${cfg.group}' - -"
    # ];

    users.users = mkIf (cfg.user == "lubelogger") {
      lubelogger = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.dataDir;
      };
    };

    users.groups = mkIf (cfg.group == "lubelogger") { lubelogger = { }; };

    networking.firewall = mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
