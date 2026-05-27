{ lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    networkmanager.enable = true;
  };

  deployment = {
    targetHost = lib.infra.machines.radiogaga.ipv4.local;
    buildOnTarget = false;
  };

  services = {
    home-assistant.enable = true;

    nginx.enable = true;

    openssh.enable = true;

    radiogaga.enable = true;
    nginx.virtualHosts."radiogaga.local".port = 4200;

    librespot = {
      enable = true;
      settings.name = "radiogaga";
    };
  };

  system.stateVersion = "22.11";
}
