{ config, lib, pkgs, ... }:

let
  cfg = config.services.hammond;
  dataDir = "/var/lib/hammond";
in
with lib;

{
  options.services.hammond = {
    enable = mkEnableOption "Hammond";

    hostName = mkOption {
      type = types.str;
      description = lib.mdDoc "FQDN for the Hammond instance.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;

      virtualHosts.${cfg.hostName} = {
        enableACME = true;
        forceSSL = true;
        root = "${pkgs.hammond}/dist";
        locations."/".extraConfig = ''
          try_files $uri /index.html;
        '';
        locations."/api".extraConfig = ''
          proxy_pass http://localhost:3000;
        '';
      };
    };

    users.users.hammond = {
      isSystemUser = true;
      group = "hammond";
      home = dataDir;
      createHome = true;
    };
    users.groups.hammond = { };

    systemd.services.hammond = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hammond}/bin/hammond";
        WorkingDirectory = "${dataDir}";
        User = "hammond";
        Type = "simple";
      };
      environment = {
        GIN_MODE = "release";
      };
    };
  };
}
