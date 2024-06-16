{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.services.deluge;
in
{
  meta.maintainers = [ maintainers.camillemndn ];

  options.services.deluge.storm = {
    enable = mkEnableOption ''A Modern Deluge Interface'';

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''Open port in the firewall for the Deluge Storm web interface.'';
    };

    port = mkOption {
      type = types.port;
      default = 8221;
      description = ''The port which the Deluge Storm web UI should listen to.'';
    };
  };

  config = mkIf cfg.storm.enable {
    systemd.services.deluge-storm = {
      description = "A Modern Deluge Interface";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.coreutils ];
      script = ''
        export DELUGE_RPC_USERNAME=$(cat "''${CREDENTIALS_DIRECTORY}/auth" | cut -d: -f1)
        export DELUGE_RPC_PASSWORD=$(cat "''${CREDENTIALS_DIRECTORY}/auth" | cut -d: -f2)
        export STORM_API_KEY=$(cat "''${CREDENTIALS_DIRECTORY}/auth" | cut -d: -f2)
        exec ${pkgs.deluge-storm}/bin/deluge-storm -l :${toString cfg.storm.port} --log-style=production -H localhost --deluge-version=v2
      '';
      serviceConfig = {
        User = "deluge";
        LoadCredential = [ "auth:${cfg.dataDir}/.config/deluge/auth" ];
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

    networking.firewall = mkIf cfg.storm.openFirewall { allowedTCPPorts = [ cfg.storm.port ]; };
  };
}
