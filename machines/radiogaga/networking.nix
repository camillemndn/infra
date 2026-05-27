{ lib, ... }:

{
  deployment = {
    targetHost = lib.infra.machines.radiogaga.ipv4.local;
    buildOnTarget = false;
  };

  networking.networkmanager.enable = true;

  services.openssh.enable = true;
}
