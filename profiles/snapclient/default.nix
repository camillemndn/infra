{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.snapclient;
in
with lib;

{
  options.services.snapclient = {
    enable = mkEnableOption "Connect to a local Snapcast server";
    serverHost = mkOption {
      type = types.str;
      example = "::";
      description = "Address/hostname of the server";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.snapclient = {
      wantedBy = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.snapcast}/bin/snapclient -h ${cfg.serverHost}";
      };
    };
  };
}
