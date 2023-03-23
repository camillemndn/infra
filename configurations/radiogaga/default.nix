{ config, ... }:

{
  networking = {
    hostName = "radiogaga";
    wireless.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  profiles.spotify.enable = true;
  profiles.radiogaga.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "22.11";
}
