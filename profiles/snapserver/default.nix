{ config, lib, ... }:

lib.mkIf config.services.snapserver.enable {
  services.snapserver = {
    openFirewall = true;
    codec = "flac";
    # sampleFormat = "44100:16:2";
    streams = {
      alsa = {
        type = "alsa";
        location = "";
        query = {
          device = "hw:0,1";
        };
      };
    };
  };

  systemd.services.snapserver = {
    after = [ "pipewire.service" ];
    requires = [ "pipewire.service" ];
    serviceConfig.SupplementaryGroups = lib.mkForce [ "audio" ];
  };
}
