{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.cloud;
in
with lib;

{
  options.profiles.cloud = {
    enable = mkEnableOption "Activate my Nextcloud instance";
  };

  config = mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud26;
      hostName = "cloud.kms";
      config.adminpassFile = "/run/secrets/nextcloud";
      enableBrokenCiphersForSSE = false;
      https = true;
      database.createLocally = true;
    };

    sops.secrets.nextcloud = {
      format = "binary";
      sopsFile = ../../secrets/nextcloud;
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nginx.virtualHosts."cloud.kms" = { enableACME = true; forceSSL = true; };
  };
}
