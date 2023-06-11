{ config, lib, ... }:

let
  cfg = config.profiles.uptime;
in
with lib;

{
  options.profiles.uptime = {
    enable = mkEnableOption "Uptime";
  };

  config = mkIf cfg.enable {
    services = {
      uptime-kuma.enable = true;

      nginx.virtualHosts."uptime.mondon.xyz" = { port = 3001; websockets = true; };

      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.mondon.xyz";
          upstream-base-url = "https://ntfy.sh";
          auth-file = "/var/lib/ntfy-sh/user.db";
          auth-default-access = "deny-all";
          listen-http = "127.0.0.1:3002";
        };
      };

      nginx.virtualHosts."ntfy.mondon.xyz".port = 3002;
    };

    systemd.services.ntfy-sh.serviceConfig.StateDirectory = "ntfy-sh";
  };
}
