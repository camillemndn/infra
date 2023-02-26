{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.deluge;
in
{
  meta.maintainers = [ maintainers.camillemndn ];

  options.services.deluge.storm = {
    enable = mkEnableOption (mdDoc ''A Modern Deluge Interface'');

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''Open port in the firewall for the Deluge Storm web interface.'';
    };

    port = mkOption {
      type = types.port;
      default = 8221;
      description = mdDoc ''The port which the Deluge Storm web UI should listen to.'';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.deluge-storm = {
      description = "A Modern Deluge Interface";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.PORT = toString cfg.port;
      serviceConfig = {
        Type = "exec";
        User = "deluge";
        ExecStart = pkgs.writeShellScript "overleaf-${service}" ''
          export $DELUGE_RPC_USER=$(cat $CREDENTIALS_DIRECTORY/$DELUGE_RPC_AUTH | cut -d: -f1)
          export $DELUGE_RPC_PASSWORD=$(cat $CREDENTIALS_DIRECTORY/$DELUGE_RPC_AUTH | cut -d: -f2)
          exec "${pkgs.deluge-storm}/bin/deluge-storm -H localhost --deluge-version=v2";
        '';
        LoadCredential = [ "DELUGE_RPC_AUTH:${cfg.dataDir}/.config/deluge/auth" ];
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
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
