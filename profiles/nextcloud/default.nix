{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.nextcloud.enable {
  services.nextcloud = {
    package = pkgs.nextcloud31;
    hostName = "cloud.mondon.xyz";

    autoUpdateApps.enable = true;
    caching.redis = true;
    database.createLocally = true;
    https = true;
    maxUploadSize = "4G";
    phpOptions."opcache.interned_strings_buffer" = "23";
    config = {
      adminuser = "Camille";
      adminpassFile = config.age.secrets.nextcloud-adminpass.path;
      dbtype = "mysql";
    };
    settings = {
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

  age.secrets.nextcloud-adminpass = {
    file = ./adminpass.age;
    owner = "nextcloud";
  };
}
