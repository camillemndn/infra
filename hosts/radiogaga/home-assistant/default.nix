{
  pkgs,
  ...
}:

{
  services = {
    home-assistant = rec {
      enable = true;

      config = {
        automation = "!include automations.yaml";
        default_config = { };
        homeassistant.name = "Cama";
        scene = "!include scenes.yaml";
      };

      customComponents = [ (package.python3Packages.callPackage ./greeclimate.nix { }) ];

      extraComponents = [
        "ecovacs"
        "jellyfin"
        "meteo_france"
        "mobile_app"
        "picotts"
        "piper"
        "radio_browser"
        "spotify"
        "stt"
        "tradfri"
        "tts"
        "wake_word"
        "zeroconf"
      ];

      extraPackages =
        p: with p; [
          aiohomekit
          py-sucks
          python-otbr-api
        ];

      openFirewall = true;
      package = pkgs.unstable.home-assistant;
    };
  };
}
