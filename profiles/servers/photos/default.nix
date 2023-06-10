{ config, lib, ... }:

let
  cfg = config.profiles.photos;
in
with lib;

{
  options.profiles.photos = {
    enable = mkEnableOption "Photos";
  };

  config = mkIf cfg.enable {
    services.photoprism = {
      enable = true;
      originalsPath = "/var/lib/nextcloud/data/Camille/files/Pictures";
      passwordFile = "/run/secrets/photos";
      settings = {
        PHOTOPRISM_ADMIN_USER = "camille";
      };
    };

    systemd.services.photoprism.serviceConfig.SupplementaryGroups = [ "nextcloud" ];

    services.nginx.virtualHosts."photos.kms".locations."/".proxyWebsockets = true;

    services.vpnVirtualHosts.photos.port = 2342;

    sops.secrets.photos = {
      format = "binary";
      owner = "root";
      sopsFile = ./password;
    };
  };
}
