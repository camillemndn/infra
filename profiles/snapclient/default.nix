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
    soundcard = mkOption {
      type = types.str;
      default = "default";
      example = "::";
      description = "Output soundcard";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.snapclient = {
      description = "Snapclient";
      wantedBy = [ "multi-user.target" ];
      after = [ "pipewire.service" ];
      requires = [ "pipewire.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.snapcast}/bin/snapclient -h ${cfg.serverHost} -s ${cfg.soundcard}";
        SupplementaryGroups = [ "audio" ];
      };
    };
  };
}
