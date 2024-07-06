{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.grafana.enable {
  services.grafana = {
    settings.server.http_port = 3001;
    declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];
  };

  services.nginx.virtualHosts."graphs.kms".port = 3001;

  services.prometheus = {
    enable = true;
    port = 9091;
    scrapeConfigs = [
      {
        job_name = "unbound";
        static_configs = [ { targets = [ "192.168.0.1:9167" ]; } ];
      }
    ];
  };
}
