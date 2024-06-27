_:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "radiogaga";
    wireless.enable = true;
    firewall.allowedTCPPorts = [ 2022 ];
  };

  profiles = {
    radiogaga.enable = true;
    spotify.enable = true;
  };

  services = {
    nginx.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "22.11";
}
