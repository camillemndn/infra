{ config, lib, ... }:
let
  dataDir = "/srv/backups";
  cfg = config.profiles.sync;
in
with lib;

{
  options.profiles.sync = {
    enable = mkEnableOption "Syncthing for zeppelin";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      inherit dataDir;
      cert = "/run/secrets/sync/cert.pem";
      key = "/run/secrets/sync/key.pem";
      extraOptions = {
        gui = {
          user = "Camille";
          insecureSkipHostcheck = true;
          insecureAllowFrameLoading = true;
        };
      };
      devices = {
        LAZULI = {
          addresses = [
          ];
          id = "TUSYARL-UJQQLPL-CNZ4UTZ-ZX3LLEY-Z2TYQ2Z-CRIJJJH-2SN7V37-RNNQ5QF";
        };
        kobo = {
          addresses = [
          ];
          id = "MXMJF63-FPGQCLG-AAMU3VP-ASQ4NNA-HT7QT52-X2OAQUQ-YCFOJPJ-IRW54Q7";
        };
      };
      folders = {
        "${dataDir}/thunderbird" = {
          id = "r97vx-4pizi";
          devices = [ "LAZULI" ];
          label = "Profil Thunderbird";
          type = "receiveonly";
          rescanInterval = 86400;
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "604800";
              maxAge = "31536000";
            };
          };
          watch = false;
        };
        "/srv/media/Bibliotheque" = {
          id = "spwtv-fzfgq";
          devices = [ "LAZULI" "kobo" ];
          label = "Calibre - Bibliothèque";
          type = "sendreceive";
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "604800";
              maxAge = "31536000";
            };
          };
        };
        "/srv/media/Bibliotheque-universitaire" = {
          id = "9zwlw-ofgpj";
          devices = [ "LAZULI" "kobo" ];
          label = "Calibre - Bibliothèque universitaire";
          type = "sendreceive";
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "604800";
              maxAge = "31536000";
            };
          };
        };
      };
    };

    services.nginx.virtualHosts."sync.zeppelin.kms" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8384";
        extraConfig = ''
          allow 100.10.10.0/8;
          deny all;
        '';
      };
    };

    users.users."syncthing".extraGroups = [ "mediasrv" ];

    sops.secrets."sync/cert.pem" = {
      format = "binary";
      sopsFile = ./cert.pem;
    };
    sops.secrets."sync/key.pem" = {
      format = "binary";
      sopsFile = ./key.pem;
    };
  };
}
