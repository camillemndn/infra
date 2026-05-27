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
  };

  system.stateVersion = "22.11";
}
