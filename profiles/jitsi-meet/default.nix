{ config, lib, ... }:

lib.mkIf config.services.jitsi-meet.enable {
  services.jitsi-meet = {
    hostName = "meet.mondon.xyz";
    excalidraw.enable = true;
    jicofo.enable = true;
    nginx.enable = true;
    prosody.enable = true;
    secureDomain.enable = true;
    videobridge.enable = true;
  };

  services.jitsi-videobridge = {
    openFirewall = true;
    nat = with lib.infra.machines.zeppelin.ipv4; {
      publicAddress = public;
      localAddress = local;
    };
  };

  services.prosody.extraConfig = ''
    log = {
      warn = "*syslog";
    }
  '';
}
