_: {
  services = {
    nginx = {
      enable = true;
      enableDefault = true;
    };

    radiogaga.enable = true;

    # Avahi comes from librespot/; AirPlay and the network sink reuse it.

    # AirPlay 2 receiver, playing through PipeWire's PulseAudio layer.
    shairport-sync = {
      enable = true;
      openFirewall = true;
      settings.general.name = "radiogaga";
    };

    # DLNA/UPnP renderer. Its DynamicUser is only in `audio`; system-wide PipeWire
    # may also require the pipewire group.
    gmediarender = {
      enable = true;
      friendlyName = "radiogaga";
      port = 49494;
      audioSink = "pipewiresink";
    };

    # PulseAudio network sink, announced over Avahi, for other PipeWire machines.
    pipewire.extraConfig.pipewire-pulse."10-network-sink" = {
      "pulse.cmd" = [
        # No cookie on the trusted LAN; auth-ip-acl=<subnet> would restrict it.
        {
          cmd = "load-module";
          args = "module-native-protocol-tcp auth-anonymous=1";
        }
        {
          cmd = "load-module";
          args = "module-zeroconf-publish";
        }
      ];
    };
  };

  # Pulse sink, MPD, Iris, UPnP renderer, SSDP; Avahi opens 5353 itself.
  networking.firewall = {
    allowedTCPPorts = [
      4713
      6600
      6680
      49494
    ];

    allowedUDPPorts = [ 1900 ];
  };

  # System-wide PipeWire: audio clients need the pipewire group.
  users.users.shairport.extraGroups = [ "pipewire" ];
  system.stateVersion = "22.11";
}
