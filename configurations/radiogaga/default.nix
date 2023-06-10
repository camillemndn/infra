_:

{
  networking = {
    hostName = "radiogaga";
    wireless.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  profiles.radiogaga.enable = true;
  profiles.spotify.enable = true;

  services.openssh.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "22.11";
}
