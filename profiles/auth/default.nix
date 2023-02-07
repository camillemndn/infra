{ config, lib, ... }:

let
  cfg = config.profiles.auth;
in
with lib;

{
  options.profiles.auth = {
    enable = mkEnableOption "Activate my Keycloak config";
  };

  config = mkIf cfg.enable {
    services.vpnVirtualHosts.auth = { service = "keycloak"; port = 8081; };

    services.keycloak = {
      enable = true;
      database.type = "mariadb";
      database.passwordFile = "/run/secrets/keycloak-db";
      settings.hostname = "auth.kms";
      initialAdminPassword = "changemeasap";
      database.createLocally = true;
      settings = {
        http-relative-path = "/auth";
        http-port = 8081;
        hostname-strict-backchannel = true;
        proxy = "edge";
      };
    };
  };
}
