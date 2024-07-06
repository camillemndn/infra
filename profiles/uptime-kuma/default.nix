{ config, lib, ... }:

{
  config = lib.mkIf config.services.uptime-kuma.enable {
    services = {
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

      nginx.virtualHosts = {
        "uptime.mondon.xyz" = {
          port = 3001;
          websockets = true;
        };
        "status.mondon.xyz" = {
          port = 3001;
          websockets = true;
        };
        "ntfy.mondon.xyz".port = 3002;
      };
    };

    systemd.services.ntfy-sh.serviceConfig.StateDirectory = "ntfy-sh";
  };
}
