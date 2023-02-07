{ config, lib, ... }:

let
  cfg = config.profiles.meet;
in
with lib;

{
  options.profiles.meet = {
    enable = mkEnableOption "Jitsi";
    hostName = mkOption {
      type = types.str;
      default = "meet.kms";
    };
  };

  config = mkIf cfg.enable {
    services.jitsi-meet = {
      enable = true;
      hostName = cfg.hostName;
    };

    services.jitsi-videobridge.nat = {
      # publicAddress = "";
      # localAddress = "";
    };

    services.nginx.virtualHosts."${cfg.hostName}" = {
      enableACME = true;
      forceSSL = true;
    };

    networking.firewall.allowedUDPPorts = [ 10000 ];
  };
}
