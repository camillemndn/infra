{ config, lib, pkgs, ... }:

let
  app = "overleaf";
  domain = "write.kms";
  dataDir = "/var/lib/${app}";
  cfg = config.services.overleaf;
in
with lib;

{
  options.services.overleaf = {
    enable = mkEnableOption "Overleaf";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;

      virtualHosts.${domain} = {
        #enableACME = true;
        #forceSSL = true;
        #root = "${pkgs.${app}}/dist";
        root = "/var/lib/${app}";
        locations."/".extraConfig = ''
          try_files $uri /index.html;
        '';
        locations."/api".extraConfig = ''
          proxy_pass http://localhost:3000;
        '';
      };
    };

    services.vpnVirtualHosts.write.port = 3032;
    services.mongodb = {
      enable = true;
      package = pkgs.mongodb-4_2;
      # bind_ip = "100.73.69.100";
    };

    services.redis.servers."" = {
      enable = true;
      # openFirewall = true;
      # bind = "100.73.69.100";
      requirePassFile = "/run/secrets/redis";
    };

    sops.secrets.redis = {
      format = "binary";
      owner = "redis";
      sopsFile = ../../../../secrets/redis;
    };

    users.users.${app} = {
      isSystemUser = true;
      group = app;
      home = dataDir;
      createHome = true;
    };
    users.groups.${app} = { };

    systemd.services."${app}" = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        # ExecStart = "${pkgs.${app}}/bin/${app}";
        WorkingDirectory = "${dataDir}";
        User = "${app}";
        Type = "simple";
      };
      environment = {
        GIN_MODE = "release";
      };
    };

    networking.firewall.allowedTCPPorts = [ 27017 ];
  };
}
