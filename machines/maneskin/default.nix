{ lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "maneskin";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  deployment = {
    allowLocalDeployment = true;
    targetHost = lib.infra.machines.maneskin.ipv4.local;
  };

  services = {
    adguardhome = {
      enable = true;
      openFirewall = true;
    };

    nginx.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "24.05";
}
