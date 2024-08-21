{ config, lib, ... }:

lib.mkIf config.services.lubelogger.enable {
  services = {
    lubelogger = {
      port = 5003;
      settings = {
        UseDarkMode = "true";
        EnableAuth = "true";
        UserNameHash = "d6475710660580fc5c6d9aeabe5d144a5c28fc0288142f18bb645338c246cc7c";
        UserPasswordHash = "c334c16159b4217aea11e212d377214d8778ebde3a03363780e901f5290dee50";
      };
    };

    nginx.virtualHosts."vehicles.kms" = {
      inherit (config.services.lubelogger) port;
      basicAuthFile = "/var/lib/lubelogger_auth";
      locations."/".extraConfig = ''
        client_max_body_size               50000M;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade    $http_upgrade;
        proxy_set_header   Connection "upgrade";
      '';
    };
  };
}
