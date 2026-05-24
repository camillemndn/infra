{
  config,
  lib,
  ...
}:

lib.mkIf config.services.mattermost.enable {
  services.mattermost = {
    database.peerAuth = true;
    siteUrl = "https://projects.mndn.fr";
  };

  services.nginx.virtualHosts."projects.mndn.fr" = {
    port = 8065;
    websockets = true;
  };
}
