{ config, lib, pkgs, ... }:

let
  cfg = config.services.hammond;
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
    services.nginx.virtualHosts.${cfg.hostName} = {
      root = "${pkgs.hammond}/dist";
      locations."/".tryFiles = "$uri /index.html";
      locations."/api".proxyPass = "http://localhost:3000";
    };

    systemd.services.hammond = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hammond}/bin/hammond";
        WorkingDirectory = "/var/lib/hammond";
        User = "hammond";
        Type = "simple";
      };
      environment.GIN_MODE = "release";
    };

    users.users.hammond = {
      isSystemUser = true;
      group = "hammond";
      home = "/var/lib/hammond";
      createHome = true;
    };
    users.groups.hammond = { };
  };
}
