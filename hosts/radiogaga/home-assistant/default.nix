{
  pkgs,
  ...
}:

{
  services = {
    home-assistant = rec {
      enable = true;
      package = pkgs.unstable.home-assistant;
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
      config = {
        default_config = { };
        homeassistant.name = "Cama";
        scene = "!include scenes.yaml";
        automation = "!include automations.yaml";
      };
    };
  };
}
