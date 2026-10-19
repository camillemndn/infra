{
  config,
  lib,
  pkgs,
  ...
}:

let
  group = "media";

  delugeCSSFilter = ''
    proxy_set_header Accept-Encoding "";
    sub_filter
      '</head>'
      '<link rel="stylesheet" type="text/css" href="https://halianelf.github.io/Deluge-Dark/deluge.css">
      </head>';
    sub_filter_once on;
  '';
in

{
  environment.systemPackages = with pkgs; [
    shntool
    cuetools
    monkeysAudio
    flac
  ];

  services = {
    bazarr = {
      inherit group;
      enable = true;
    };

    calibre-server = {
      inherit group;
      enable = true;

      libraries = [
        "/srv/media/Bibliotheque"
        "/srv/media/Bibliotheque-universitaire"
      ];
    };

    calibre-web = {
      inherit group;
      options.calibreLibrary = "/srv/media/Bibliotheque";
      listen.ip = "127.0.0.1";
      package = pkgs.unstable.calibre-web;
    };

    deluge = {
      inherit group;
      enable = true;
      web.enable = true;
    };

    flood = {
      enable = true;
      port = 3022;
    };

    jackett = {
      inherit group;
      enable = true;
      package = pkgs.unstable.jackett;
    };

    jellyfin = {
      inherit group;
      enable = true;
    };

    lidarr = {
      inherit group;
      enable = true;
    };

    lidarr-youtube-downloader = {
      enable = true;
      downloadPath = "/srv/media/Téléchargements";
      group = "media";
      musicPath = "/srv/media/Musique";
    };

    nginx = {
      publicDomains = [ "mndn.fr" ];

      virtualHosts = {
        "deluge.kms" = {
          extraConfig = delugeCSSFilter;
          port = 8112;
        };

        "manage.library.kms".port = 8079;

        "media.kms" = {
          port = 8096;
          websockets = true;
        };

        "media.mndn.fr" = {
          port = 8096;
          websockets = true;
        };

        "movies.kms" = {
          port = 7878;
          websockets = true;
        };

        "music.kms" = {
          port = 8686;
          websockets = true;
        };

        "requests.kms".port = 5055;
        "requests.mndn.fr".port = 5055;

        "series.kms" = {
          port = 8989;
          websockets = true;
        };

        "subtitles.kms" = {
          port = 6767;
          websockets = true;
        };

        "torrents.kms".port = 3022;
        "trackers.kms".port = 9117;
      };
    };

    radarr = {
      inherit group;
      enable = true;
    };

    seerr.enable = true;

    sonarr = {
      inherit group;
      enable = true;
    };
  };

  systemd.services.calibre-server.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.calibre}/bin/calibre-server --enable-auth ${lib.concatStringsSep " " config.services.calibre-server.libraries} --port 8079";

  users = {
    groups.${group}.name = group;
    users.camille.extraGroups = [ group ];
  };
}
