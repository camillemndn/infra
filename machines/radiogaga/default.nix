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
      openFirewall = true;
      config.homeassistant.name = "Cama";
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
  };

  system.stateVersion = "22.11";
}
