{
  config,
  pkgs,
  ...
}:

let
  officeDomain = "office.mndn.fr";
in

{
  age.secrets.nextcloud-adminpass = {
    file = ./adminpass.age;
    owner = "nextcloud";
  };

  services = {
    collabora-online = {
      enable = true;
      # Documents are only opened from Nextcloud.
      aliasGroups = [ { host = "https://${config.services.nextcloud.hostName}:443"; } ];

      settings = {
        server_name = officeDomain;

        # nginx and Nextcloud reach it on 127.0.0.1.
        net = {
          listen = "loopback";
          proto = "IPv4";
        };

        # nginx terminates TLS.
        ssl = {
          enable = false;
          termination = true;
        };
      };
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud34;
      hostName = "cloud.mndn.fr";
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
        default_phone_region = "FR";
        mail_smtphost = "mail.luj.fr";
        mail_smtpport = 465;
        mail_smtpsecure = "ssl";
        mail_smtpauth = true;
        mail_smtpname = "camille";
        mail_from_address = "cloud";
        mail_domain = "mondon.me";
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

    nginx.virtualHosts.${officeDomain} = {
      inherit (config.services.collabora-online) port;
      websockets = true;
    };

    redis.servers.nextcloud = {
      enable = true;
      user = "nextcloud";
      port = 0;
    };
  };
}
