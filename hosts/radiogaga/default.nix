{ pkgs, ... }:

{
  deployment = {
    # Off the tailnet: its mDNS name, from the LAN.
    targetHost = "radiogaga.local";
    buildOnTarget = false;
    allowLocalDeployment = false;
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

  nix.settings.auto-optimise-store = false;

  services = {
    nginx = {
      enable = true;
      enableDefault = true;
    };

    radiogaga.enable = true;
    tailscale.enable = false;

    # Avahi comes from librespot/; AirPlay and the network sink reuse it.

    # AirPlay 2 receiver, playing through PipeWire's PulseAudio layer.
    shairport-sync = {
      enable = true;
      openFirewall = true;
      settings.general.name = "radiogaga";
    };

    # DLNA/UPnP renderer, playing through system-wide PipeWire.
    gmediarender = {
      enable = true;
      friendlyName = "radiogaga";
      port = 49494;
      audioSink = "pipewiresink";
    };

    pipewire = {
      enable = true;
      systemWide = true;

      # PulseAudio network sink, announced over Avahi, for other PipeWire machines.
      extraConfig.pipewire-pulse."10-network-sink" = {
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
  };

  # Its evaluation needs over 1 GB, more than the Pi has.
  services.comin.enable = false;

  # System-wide PipeWire: audio clients need the pipewire group.
  systemd.services.gmediarender = {
    serviceConfig.SupplementaryGroups = [ "pipewire" ];

    environment = {
      GST_PLUGIN_PATH_1_0 = "${pkgs.pipewire}/lib/gstreamer-1.0";
      # GStreamer's HTTP source needs a GIO TLS backend for Navidrome HTTPS URLs.
      GIO_EXTRA_MODULES = "${pkgs.glib-networking}/lib/gio/modules";
    };
  };

  users.users.shairport.extraGroups = [ "pipewire" ];
  system.stateVersion = "22.11";
}
