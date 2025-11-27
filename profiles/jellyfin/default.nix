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
      package = pkgs.unstable.jackett.overrideAttrs (
        _: _:
        let
          ygg-api = pkgs.fetchurl {
            url = "https://gist.github.com/Clemv95/8bfded23ef23ec78f6678896f42a2b60/raw/350af94aa453148e5a5f1811debfa1ae9e46cc9a/ygg-api.yml";
            hash = "sha256-6X8mF1AXTkdJ9NAoO238XHZu9nFT7JJOknsL4ZCLzIE=";
          };
        in
        {
          postInstall = ''
            cp ${ygg-api} $out/lib/jackett/Definitions/ygg-api.yml
          '';
        }
      );
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
    monkeysAudio
    flac
  ];

  systemd.services.calibre-server.serviceConfig.ExecStart =
    lib.mkForce "${pkgs.calibre}/bin/calibre-server --enable-auth ${lib.concatStringsSep " " config.services.calibre-server.libraries} --port 8079";
}
