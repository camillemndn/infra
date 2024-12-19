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

lib.mkIf config.services.jellyfin.enable {
  users.groups.${group}.name = group;

  services = {
    bazarr = {
      enable = true;
      inherit group;
    };
    nginx.virtualHosts."subtitles.kms" = {
      port = 6767;
      websockets = true;
    };

    calibre-server = {
      enable = true;
      inherit group;
      libraries = [
        "/srv/media/Bibliotheque"
        "/srv/media/Bibliotheque-universitaire"
      ];
    };
    nginx.virtualHosts."manage.library.kms".port = 8079;

    calibre-web = {
      enable = true;
      inherit group;
      listen.ip = "127.0.0.1";
      options.calibreLibrary = "/srv/media/Bibliotheque";
    };
    nginx.virtualHosts."library.kms".port = 8083;
    nginx.virtualHosts."library.mondon.xyz".port = 8083;

    deluge = {
      enable = true;
      inherit group;
      web.enable = true;
    };
    nginx.virtualHosts."deluge.kms" = {
      port = 8112;
      extraConfig = delugeCSSFilter;
    };

    flood = {
      enable = true;
      port = 3022;
    };
    nginx.virtualHosts."torrents.kms".port = 3022;

    jackett = {
      enable = true;
      inherit group;
      package = pkgs.jackett;
    };
    nginx.virtualHosts."trackers.kms".port = 9117;

    jellyfin = {
      inherit group;
    };
    nginx.virtualHosts."media.kms" = {
      port = 8096;
      websockets = true;
    };
    nginx.virtualHosts."media.mondon.xyz" = {
      port = 8096;
      websockets = true;
    };

    jellyseerr.enable = true;
    nginx.virtualHosts."requests.kms".port = 5055;
    nginx.virtualHosts."requests.mondon.xyz".port = 5055;

    lidarr = {
      enable = true;
      inherit group;
    };
    nginx.virtualHosts."music.kms" = {
      port = 8686;
      websockets = true;
    };

    radarr = {
      enable = true;
      inherit group;
    };
    nginx.virtualHosts."movies.kms" = {
      port = 7878;
      websockets = true;
    };

    sonarr = {
      enable = true;
      inherit group;
    };
    nginx.virtualHosts."series.kms" = {
      port = 8989;
      websockets = true;
    };
  };

  environment.systemPackages = with pkgs; [
    shntool
    cuetools
    mac
    flac
  ];

  systemd.services.calibre-server.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.calibre}/bin/calibre-server --enable-auth ${lib.concatStringsSep " " config.services.calibre-server.libraries} --port 8079";
}
