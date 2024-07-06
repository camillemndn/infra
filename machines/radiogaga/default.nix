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
    nginx.enable = true;
    nginx.virtualHosts."radiogaga.local".port = 4200;
    openssh.enable = true;
    radiogaga.enable = true;
    spotifyd.enable = true;
    spotifyd.settings.global.device_name = "radiogaga";
  };

  system.stateVersion = "22.11";
}
