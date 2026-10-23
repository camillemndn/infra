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
        "radio_browser"
        "spotify"
        "tradfri"
        "tts"
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
