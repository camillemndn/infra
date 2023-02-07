{ lib, config, pkgs, ... }:

let
  cfg = config.services.logiops;
in
with lib;

{
  options.services.logiops = {
    enable = mkEnableOption "Logiops";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.logiops ];

    environment.etc."logid.cfg".source = ./logid.cfg;

    systemd.services.logid = {
      enable = true;
      description = "Logitech configuration daemon";
      unitConfig = {
        StartLimitIntervalSec = "0";
        After = "multi-user.target";
        Wants = "multi-user.target";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid";
        User = "root";
        ExecReload = "/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
    };
  };
}
