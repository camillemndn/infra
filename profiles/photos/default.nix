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
      originalsPath = "/srv/cloud/camille/Pictures";
      passwordFile = "/run/secrets/photos";
      settings = {
        PHOTOPRISM_ADMIN_USER = "camille";
      };
    };

    systemd.services.photoprism.serviceConfig.SupplementaryGroups = [ "filerun" ];

    services.nginx.virtualHosts."photos.kms".locations."/".proxyWebsockets = true;

    #systemd.services.photoprism.serviceConfig.SupplementaryGroups = [ "filerun" ];

    services.vpnVirtualHosts.photos.port = 2342;

    sops.secrets.photos = {
      format = "binary";
      owner = "root";
      sopsFile = ../../secrets/photos;
    };
  };
}
