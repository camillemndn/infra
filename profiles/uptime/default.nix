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
      uptime-kuma = {
        enable = true;
        settings.NODE_EXTRA_CA_CERTS = "/etc/nixos/users/saumonnet.crt";
      };
      acmeVirtualHosts.uptime.port = 3001;

      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.mondon.xyz";
          upstream-base-url = "https://ntfy.sh";
          auth-file = "/var/lib/ntfy-sh/user.db";
          auth-default-access = "deny-all";
          listen-http = ":3002";
        };
      };
      acmeVirtualHosts.ntfy.port = 3002;
    };

    security.acme.defaults.server = mkForce "https://acme-v02.api.letsencrypt.org/directory";

    systemd.services.ntfy-sh.serviceConfig.StateDirectory = "ntfy-sh";
    services.nginx.virtualHosts."uptime.mondon.xyz".locations."/".proxyWebsockets = true;

    # sqlite3 /var/lib/uptime-kuma/kuma.db "select * from monitor;"
  };
}
