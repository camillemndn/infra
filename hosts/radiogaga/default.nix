{ config, pkgs, ... }:

{
  deployment = {
    # Off the tailnet: its mDNS name, from the LAN.
    targetHost = "radiogaga.local";
    buildOnTarget = false;
    allowLocalDeployment = false;
  };

  # Holds HOME_WIFI_SSID=<name> and HOME_WIFI_PSK=<passphrase>, substituted into the Wi-Fi profile at activation.
  age.secrets.wifi.file = ./wifi.age;

  networking = {
    # Pulse sink, UPnP renderer, SSDP; Avahi opens 5353 itself.
    firewall = {
      allowedTCPPorts = [
        4713
        49494
      ];

      allowedUDPPorts = [ 1900 ];
    };

    # No cellular modem; NetworkManager would otherwise start ModemManager.
    modemmanager.enable = false;

    networkmanager.ensureProfiles = {
      environmentFiles = [ config.age.secrets.wifi.path ];

      profiles.home = {
        connection = {
          id = "home";
          type = "wifi";
          interface-name = "wlan0";
        };

        wifi = {
          mode = "infrastructure";
          ssid = "$HOME_WIFI_SSID";
        };

        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$HOME_WIFI_PSK";
        };

        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    };
  };

  nix.settings.auto-optimise-store = false;

  services = {
    tailscale.enable = false;
    # Avahi comes from librespot/; AirPlay and the network sink reuse it.
    resolved.settings.Resolve.MulticastDNS = "no";
    avahi.nssmdns4 = true;

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

  # The socket creates /run/pulse as root; the server also needs to write its PID.
  systemd.services.pipewire-pulse.serviceConfig = {
    RuntimeDirectory = "pulse";
    RuntimeDirectoryPreserve = "yes";
  };

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
