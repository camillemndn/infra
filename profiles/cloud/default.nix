{
  config,
  lib,
  pkgs,
  ...
}:

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
      package = pkgs.nextcloud29;
      hostName = "cloud.mondon.xyz";

      autoUpdateApps.enable = true;
      caching.redis = true;
      database.createLocally = true;
      https = true;
      maxUploadSize = "4G";
      phpOptions."opcache.interned_strings_buffer" = "23";
      config = {
        adminuser = "Camille";
        adminpassFile = "/run/secrets/nextcloud";
        dbtype = "mysql";
      };
      settings = {
        default_phone_region = "FR";
        overwriteprotocol = "https";
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
          "OC\\Preview\\MSOffice2003"
          "OC\\Preview\\MSOffice2007"
          "OC\\Preview\\MSOfficeDoc"
          "OC\\Preview\\PDF"
          "OC\\Preview\\Photoshop"
          "OC\\Preview\\Postscript"
          "OC\\Preview\\SVG"
          "OC\\Preview\\TIFF"
        ];
      };
    };

    services.redis.servers.nextcloud = {
      enable = true;
      user = "nextcloud";
      port = 0;
    };

    sops.secrets.nextcloud = {
      format = "binary";
      sopsFile = ./adminpass;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
}
