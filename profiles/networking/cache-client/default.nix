{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.cache-client;
in
with lib;

{
  options.profiles.cache-client = {
    enable = mkEnableOption "Attic client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.attic-client ];

    systemd.services.attic-watch-store = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.attic-client}/bin/attic watch-store camille";
        Restart = "on-failure";
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
