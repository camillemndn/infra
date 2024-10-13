_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "radiogaga";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  deployment = {
    targetHost = "radiogaga.local";
    buildOnTarget = false;
  };

  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        "ecovacs"
        "jellyfin"
        "meteo_france"
        "mobile_app"
        "picotts"
        "piper"
        "radio_browser"
        "snapcast"
        "spotify"
        "stt"
        "tradfri"
        "tts"
        "zeroconf"
        "wake_word"
        "whisper"
        "wyoming"
      ];
      openFirewall = true;
      config = {
        default_config = { };
        homeassistant.name = "Cama";
      };
    };

    nginx.enable = true;

    openssh.enable = true;

    radiogaga.enable = true;
    nginx.virtualHosts."radiogaga.local".port = 4200;

    snapserver.enable = true;
    snapclient = {
      enable = true;
      serverHost = "radiogaga.local";
      soundcard = "sysdefault:CARD=Headphones";
    };

    spotifyd = {
      enable = true;
      settings.global.device_name = "radiogaga";
    };

    wyoming = {
      faster-whisper.servers.ha = {
        enable = true;
        uri = "tcp://0.0.0.0:10300";
        language = "fr";
      };

      piper.servers.ha = {
        enable = true;
        uri = "tcp://0.0.0.0:10200";
        voice = "fr_FR-upmc-medium";
      };
    };
  };

  system.stateVersion = "22.11";
}
