{ config, lib, ... }:

{
  config = lib.mkIf config.services.uptime-kuma.enable {
    services = {
      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.mndn.fr";
          upstream-base-url = "https://ntfy.sh";
          auth-file = "/var/lib/ntfy-sh/user.db";
          auth-default-access = "deny-all";
          listen-http = "127.0.0.1:3002";
        };
      };

      nginx.virtualHosts = {
        "uptime.mndn.fr" = {
          port = 3001;
          websockets = true;
        };
        "status.mndn.fr" = {
          port = 3001;
          websockets = true;
        };
        "ntfy.mndn.fr" = {
          port = 3002;
          websockets = true;
        };
      };
    };

    systemd.services.ntfy-sh.serviceConfig.StateDirectory = "ntfy-sh";
  };
}
