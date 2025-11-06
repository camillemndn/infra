{
  config,
  lib,
  ...
}:

lib.mkIf config.services.mattermost.enable {
  services.mattermost = {
    database.peerAuth = true;
    siteUrl = "https://projects.mondon.xyz";
  };

  services.nginx.virtualHosts."projects.mondon.xyz" = {
    port = 8065;
    websockets = true;
  };
}
