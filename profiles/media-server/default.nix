{ lib, config, pkgs, ... }:

let
  cfg = config.profiles.media-server;
in
with lib;

{
  options.profiles.media-server = {
    enable = mkEnableOption "Activate my media server";
  };

  config = mkIf cfg.enable {
    users.groups.mediasrv.name = "mediasrv";

    services = {
      jellyfin = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.media = { port = 8096; restricted = false; };

      jellyseerr = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.requests = { port = 5055; restricted = false; };

      calibre-server = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.library.port = 8080;

      # calibre-web-litterature = { enable = true; group = "mediasrv"; };
      # vpnVirtualHosts."litterature.library" = { port = 8083; restricted = false; }; 

      # calibre-web-university = { enable = true; group = "mediasrv"; };
      # vpnVirtualHosts."university.library" = { port = 8084; restricted = false; };

      # calibre-web-tangente = { enable = true; group = "mediasrv"; };
      # vpnVirtualHosts."tangente.library" = { port = 8085; restricted = false; };

      deluge = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.torrents.port = 8112;

      radarr = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.movies.port = 7878;

      readarr = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.books2.port = 8787;

      lidarr = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.music.port = 8686;

      sonarr = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.series.port = 8989;

      bazarr = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.subtitles.port = 6767;

      jackett = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.trackers.port = 9117;

      lazylibrarian = { enable = true; group = "mediasrv"; };
      vpnVirtualHosts.books = { port = 5299; restricted = false; };
    };

    # systemd.services.jellyfin.serviceConfig = {
    #   MemoryHigh = "512M";
    #   MemoryMax = "1G";
    # };
    services.nginx.virtualHosts."media.${config.services.vpnDomain}".locations."/".proxyWebsockets = true;
    services.nginx.virtualHosts."media.${config.services.publicDomain}".locations."/".proxyWebsockets = true;

    services.calibre-server.libraries = [ "/srv/media/Bibliotheque" "/srv/media/Bibliotheque-universitaire" ];
    systemd.services.calibre-server.serviceConfig.ExecStart = mkForce ("${pkgs.calibre}/bin/calibre-server --enable-auth ${lib.concatStringsSep " " config.services.calibre-server.libraries}");

    services.deluge.web.enable = true;
    services.nginx.virtualHosts."torrents.${config.services.vpnDomain}".locations."/".extraConfig = ''
      proxy_set_header Accept-Encoding "";
      sub_filter
        '</head>'
        '<link rel="stylesheet" type="text/css" href="https://halianelf.github.io/Deluge-Dark/deluge.css">
        </head>';
      sub_filter_once on;
    '';

    services.nginx.virtualHosts."music.${config.services.vpnDomain}".locations."/".proxyWebsockets = true;
    environment.systemPackages = with pkgs; [ shntool cuetools mac flac ];
  };
}
