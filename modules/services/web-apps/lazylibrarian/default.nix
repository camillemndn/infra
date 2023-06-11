{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.lazylibrarian;
in
{
  options = {
    services.lazylibrarian = {
      enable = mkEnableOption "LazyLibrarian";

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the LazyLibrarian web interface.";
      };

      user = mkOption {
        type = types.str;
        default = "lazylibrarian";
        description = "User under which LazyLibrarian runs.";
      };

      group = mkOption {
        type = types.str;
        default = "lazylibrarian";
        description = "Group under which LazyLibrarian runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.lazylibrarian = {
      description = "LazyLibrarian";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        StateDirectory = "lazylibrarian";
        DynamicUser = true;
        ExecStart = "${pkgs.lazylibrarian}/bin/lazylibrarian --datadir $STATE_DIRECTORY";
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
      allowedTCPPorts = [ 5299 ];
    };

    users.users = mkIf (cfg.user == "lazylibrarian") {
      lazylibrarian = {
        inherit (cfg) group;
        home = "/var/lib/lazylibrarian";
        createHome = true;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "lazylibrarian") {
      lazylibrarian.gid = config.ids.gids.lazylibrarian;
    };
  };
}
