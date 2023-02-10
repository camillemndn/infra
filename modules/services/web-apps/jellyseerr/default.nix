{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.jellyseerr;
in
{
  options = {
    services.jellyseerr = {
      enable = mkEnableOption "Jellyseerr";

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the Jellyseerr web interface.";
      };

      user = mkOption {
        type = types.str;
        default = "jellyseerr";
        description = "User under which Jellyseerr runs.";
      };

      group = mkOption {
        type = types.str;
        default = "jellyseerr";
        description = "Group under which Jellyseerr runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.jellyseerr = {
      description = "Jellyseerr";
      after = [ "network.target" ];
      environment = { "NODE_ENV" = "dev"; "DEBUG" = "*"; };
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        StateDirectory = "jellyseerr";
        WorkingDirectory = "${pkgs.jellyseerr}/libexec/jellyseerr/deps/jellyseerr";
        DynamicUser = true;
        SupplementaryGroups = [ cfg.group ];
        ExecStart = "${pkgs.jellyseerr}/bin/jellyseerr";
        BindPaths = [ "/var/lib/jellyseerr/:${pkgs.jellyseerr}/libexec/jellyseerr/deps/jellyseerr/config/" ];
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

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5055 ];
    };
  };
}
