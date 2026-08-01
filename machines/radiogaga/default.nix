_: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  services = {
    home-assistant.enable = true;
    librespot = {
      enable = true;
      settings.name = "radiogaga";
    };
    nginx = {
      enable = true;
      enableDefault = true;
      virtualHosts."radiogaga.local".port = 4200;
    };
    radiogaga.enable = true;

    # Headless player that streams from zeppelin's Navidrome (Subsonic API).
    # Control it from Android via the Iris web UI (:6680/iris) or an MPD client
    # (:6600). Configured in profiles/mopidy (secret creds via agenix).
    mopidy.enable = true;

    # NB: Avahi (with publish + userServices) is already enabled by the
    # profiles/librespot module, which is active because librespot is enabled
    # above. The AirPlay receiver and the network sink below reuse it for mDNS.

    # AirPlay 2 receiver: shows up as "radiogaga" to iOS/macOS. Outputs through
    # PipeWire's PulseAudio compatibility (the module's default backend); the
    # service user is granted the "pulse" group automatically.
    shairport-sync = {
      enable = true;
      openFirewall = true;
      settings.general.name = "radiogaga";
    };

    # DLNA/UPnP renderer: lets Android/BubbleUPnP-style apps push audio here.
    # NOTE: runs as a DynamicUser in the "audio" group only; under system-wide
    # PipeWire the output routing may need the service added to the pipewire
    # group after the first deploy — verify with `journalctl -u gmediarender`.
    gmediarender = {
      enable = true;
      friendlyName = "radiogaga";
      port = 49494;
      audioSink = "pipewiresink";
    };

    # Expose PipeWire as a PulseAudio sink over the network (4713/tcp) and
    # publish it via Avahi. This is the "wifi speaker" path for another Linux /
    # NixOS machine: its PipeWire, with module-zeroconf-discover loaded, then
    # sees "radiogaga" as a selectable output device.
    pipewire.extraConfig.pipewire-pulse."10-network-sink" = {
      "pulse.cmd" = [
        # auth-anonymous lets LAN clients connect without sharing a PulseAudio
        # cookie. Fine for a living-room speaker on a trusted network; tighten
        # with `auth-ip-acl=<subnet>` instead if you want to restrict it.
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

  # PulseAudio network sink (4713/tcp); Mopidy MPD (6600/tcp) and Iris web
  # (6680/tcp); UPnP renderer http (49494/tcp) and SSDP discovery (1900/udp).
  # Avahi opens 5353/udp on its own.
  networking.firewall = {
    allowedTCPPorts = [
      4713
      6600
      6680
      49494
    ];
    allowedUDPPorts = [ 1900 ];
  };

  system.stateVersion = "22.11";
}
