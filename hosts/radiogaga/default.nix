_:

{
  deployment = {
    allowLocalDeployment = false;
    buildOnTarget = false;
    # Off the tailnet: its mDNS name, from the LAN.
    targetHost = "radiogaga.local";
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

  services = {
    # DLNA/UPnP renderer. Its DynamicUser is only in `audio`; system-wide PipeWire
    # may also require the pipewire group.
    gmediarender = {
      enable = true;
      audioSink = "pipewiresink";
      friendlyName = "radiogaga";
      port = 49494;
    };

    nginx = {
      enable = true;
      enableDefault = true;
    };

    pipewire = {
      enable = true;

      # PulseAudio network sink, announced over Avahi, for other PipeWire machines.
      extraConfig.pipewire-pulse."10-network-sink" = {
        "pulse.cmd" = [
          # No cookie on the trusted LAN; auth-ip-acl=<subnet> would restrict it.
          {
            args = "module-native-protocol-tcp auth-anonymous=1";
            cmd = "load-module";
          }
          {
            args = "module-zeroconf-publish";
            cmd = "load-module";
          }
        ];
      };

      systemWide = true;
    };

    radiogaga.enable = true;

    # Avahi comes from librespot/; AirPlay and the network sink reuse it.

    # AirPlay 2 receiver, playing through PipeWire's PulseAudio layer.
    shairport-sync = {
      enable = true;
      openFirewall = true;
      settings.general.name = "radiogaga";
    };

    tailscale.enable = false;
  };

  # Its evaluation needs over 1 GB, more than the Pi has.
  services.comin.enable = false;
  system.stateVersion = "22.11";
  # System-wide PipeWire: audio clients need the pipewire group.
  users.users.shairport.extraGroups = [ "pipewire" ];
}
