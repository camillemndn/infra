_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "rush";
    hostId = "b8ed114c";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    nginx.enable = true;

    openssh.enable = true;

    radiogaga.enable = true;
    nginx.virtualHosts."rush.local".port = 4200;

    snapserver.enable = true;
    snapclient = {
      enable = true;
      serverHost = "127.0.0.1";
      soundcard = "sysdefault:CARD=Headphones";
    };

    spotifyd = {
      enable = true;
      settings.global.device_name = "rush";
    };
  };

  system.stateVersion = "24.05";
}
