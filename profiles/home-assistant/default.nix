{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.home-assistant.enable {
  services = {
    home-assistant = {
      package = pkgs.unstable.home-assistant;
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
      extraPackages =
        p: with p; [
          aiohomekit
          py-sucks
          python-otbr-api
        ];
      openFirewall = true;
      config = {
        default_config = { };
        homeassistant.name = "Cama";
        scene = "!include scenes.yaml";
        automation = "!include automations.yaml";
      };
    };

    wyoming = {
      faster-whisper = {
        package = pkgs.unstable.wyoming-faster-whisper;
        servers.ha = {
          enable = true;
          uri = "tcp://0.0.0.0:10300";
          language = "en";
        };
      };

      piper.servers.ha = {
        enable = true;
        uri = "tcp://0.0.0.0:10200";
        voice = "en-us-ryan-medium";
      };
    };
  };
}
