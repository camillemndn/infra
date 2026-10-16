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
  services = {
    jellyfin = {
      enable = true;
      inherit group;
    };

    nginx = {
      publicDomains = [ "mndn.fr" ];

      virtualHosts = {
        "subtitles.kms" = {
          port = 6767;
          websockets = true;
        };

        "manage.library.kms".port = 8079;

        "deluge.kms" = {
          port = 8112;
          extraConfig = delugeCSSFilter;
        };

        "torrents.kms".port = 3022;
        "trackers.kms".port = 9117;

        "media.kms" = {
          port = 8096;
          websockets = true;
        };

        "media.mndn.fr" = {
          port = 8096;
          websockets = true;
        };

        "requests.kms".port = 5055;
        "requests.mndn.fr".port = 5055;

        "music.kms" = {
          port = 8686;
          websockets = true;
        };

        "movies.kms" = {
          port = 7878;
          websockets = true;
        };

        "series.kms" = {
          port = 8989;
          websockets = true;
        };
      };
    };

    bazarr = {
      enable = true;
      inherit group;
    };

    calibre-server = {
      enable = true;
      inherit group;
      libraries = [
        "/srv/media/Bibliotheque"
        "/srv/media/Bibliotheque-universitaire"
      ];
    };

    calibre-web = {
      enable = false;
      package = pkgs.unstable.calibre-web;
      inherit group;
      listen.ip = "127.0.0.1";
      options.calibreLibrary = "/srv/media/Bibliotheque";
    };

    deluge = {
      enable = true;
      inherit group;
      web.enable = true;
    };

    flood = {
      enable = true;
      port = 3022;
    };

    jackett = {
      enable = true;
      inherit group;
      package = pkgs.unstable.jackett;
    };

    seerr.enable = true;

    lidarr = {
      enable = true;
      inherit group;
    };

    radarr = {
      enable = true;
      inherit group;
    };

    lidarr-youtube-downloader = {
      enable = true;
      group = "media";
      downloadPath = "/srv/media/Téléchargements";
      musicPath = "/srv/media/Musique";
    };

    sonarr = {
      enable = true;
      inherit group;
    };
  };

  users.groups.${group}.name = group;
  environment.systemPackages = with pkgs; [
    shntool
    cuetools
    monkeysAudio
    flac
  ];
  systemd.services.calibre-server.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.calibre}/bin/calibre-server --enable-auth ${lib.concatStringsSep " " config.services.calibre-server.libraries} --port 8079";
}
