{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.media-server;
  group = "media";
in
with lib;

{
  options.profiles.media-server = {
    enable = mkEnableOption "Activate my media server";
  };

  config = mkIf cfg.enable {
    users.groups.${group}.name = group;

    services = {
      jellyfin = { enable = true; inherit group; };
      vpnVirtualHosts.media = { port = 8096; restricted = false; };

      jellyseerr.enable = true;
      vpnVirtualHosts.requests = { port = 5055; restricted = false; };

      calibre-server = { enable = true; inherit group; };
      vpnVirtualHosts.library.port = 8079;

      # calibre-web-litterature = { enable = true; inherit group; };
      # vpnVirtualHosts."litterature.library" = { port = 8083; restricted = false; }; 

      # calibre-web-university = { enable = true; inherit group; };
      # vpnVirtualHosts."university.library" = { port = 8084; restricted = false; };

      # calibre-web-tangente = { enable = true; inherit group; };
      # vpnVirtualHosts."tangente.library" = { port = 8085; restricted = false; };

      deluge = { enable = true; inherit group; storm.enable = true; };
      vpnVirtualHosts.torrents.port = 8112;
      vpnVirtualHosts.storm.port = 8221;

      radarr = { enable = true; inherit group; };
      vpnVirtualHosts.movies.port = 7878;

      lidarr = { enable = true; inherit group; };
      vpnVirtualHosts.music.port = 8686;

      sonarr = { enable = true; inherit group; };
      vpnVirtualHosts.series.port = 8989;

      bazarr = { enable = true; inherit group; };
      vpnVirtualHosts.subtitles.port = 6767;

      jackett = { enable = true; inherit group; };
      vpnVirtualHosts.trackers.port = 9117;

      lazylibrarian = { enable = true; inherit group; };
      vpnVirtualHosts.books = { port = 5299; restricted = false; };

      # readarr = { enable = true; inherit group; };
      # vpnVirtualHosts.books2.port = 8787;
    };

    systemd.services.lazylibrarian.serviceConfig.TimeoutStopSec = 5;

    # systemd.services.jellyfin.serviceConfig = {
    #   MemoryHigh = "512M";
    #   MemoryMax = "1G";
    # };
    services.nginx.virtualHosts."media.${config.services.vpnDomain}".locations."/".proxyWebsockets = true;
    services.nginx.virtualHosts."media.${config.services.publicDomain}".locations."/".proxyWebsockets = true;

    services.calibre-server.libraries = [ "/srv/media/Bibliotheque" "/srv/media/Bibliotheque-universitaire" ];
    systemd.services.calibre-server.serviceConfig.ExecStart = mkForce "${pkgs.calibre}/bin/calibre-server --enable-auth ${lib.concatStringsSep " " config.services.calibre-server.libraries} --port 8079";

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
