{ config, lib, pkgs, ... }:

let
  app = "hammond";
  domain = "car.kms";
  dataDir = "/var/lib/${app}";
  cfg = config.services.hammond;
in
with lib;

{
  options.services.hammond = {
    enable = mkEnableOption "Hammond";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;

      virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        root = "${pkgs.${app}}/dist";
        locations."/".extraConfig = ''
          try_files $uri /index.html;
        '';
        locations."/api".extraConfig = ''
          proxy_pass http://localhost:3000;
        '';
      };
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
        ExecStart = "${pkgs.${app}}/bin/${app}";
        WorkingDirectory = "${dataDir}";
        User = "${app}";
        Type = "simple";
      };
      environment = {
        GIN_MODE = "release";
      };
    };
  };
}
