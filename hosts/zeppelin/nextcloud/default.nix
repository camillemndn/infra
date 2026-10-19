{
  config,
  pkgs,
  ...
}:

{
  age.secrets.nextcloud-adminpass = {
    file = ./adminpass.age;
    owner = "nextcloud";
  };

  services = {
    nextcloud = {
      enable = true;
      autoUpdateApps.enable = true;
      caching.redis = true;

      config = {
        adminpassFile = config.age.secrets.nextcloud-adminpass.path;
        adminuser = "Camille";
        dbtype = "mysql";
      };

      database.createLocally = true;
      hostName = "cloud.mndn.fr";
      https = true;
      maxUploadSize = "4G";
      package = pkgs.nextcloud34;
      phpOptions."opcache.interned_strings_buffer" = "23";

      settings = {
        default_phone_region = "FR";

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

        mail_domain = "mondon.me";
        mail_from_address = "cloud";
        mail_smtpauth = true;
        mail_smtphost = "mail.luj.fr";
        mail_smtpname = "camille";
        mail_smtpport = 465;
        mail_smtpsecure = "ssl";
        overwriteprotocol = "https";
      };
    };

    redis.servers.nextcloud = {
      enable = true;
      port = 0;
      user = "nextcloud";
    };
  };
}
