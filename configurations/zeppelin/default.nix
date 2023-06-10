_:

{
  networking = {
    hostName = "zeppelin";
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    hammond = { enable = true; hostName = "car.kms"; };
    openssh.enable = true;
    tailscale.enable = true;
    webtrees = { enable = true; hostName = "family.mondon.xyz"; };
  };

  profiles = {
    binary-cache = { enable = true; hostName = "cache"; };
    cloud.enable = true;
    feeds.enable = true;
    graphs.enable = true;
    mail-server.enable = true;
    media-server.enable = true;
    meet = { enable = true; hostName = "meet.mondon.xyz"; };
    passwords.enable = true;
    photos.enable = true;
    websites.enable = true;
  };

  system.stateVersion = "21.11";
}

