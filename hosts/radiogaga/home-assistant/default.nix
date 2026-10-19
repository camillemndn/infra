{
  pkgs,
  ...
}:

{
  services = {
    home-assistant = rec {
      enable = true;

      # Backport the verification-loop fix until the pinned packages include it:
      # https://github.com/home-assistant/core/pull/186796
      # https://github.com/DeebotUniverse/client.py/pull/1743
      package =
        (pkgs.unstable.home-assistant.override {
          packageOverrides = _: prev: {
            deebot-client = prev.deebot-client.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [ ./deebot-account-credentials.patch ];
            });
          };
        }).overrideAttrs
          (old: {
            patches = old.patches ++ [ ./ecovacs-persist-credentials.patch ];
          });

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
