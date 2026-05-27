_: {
  deployment = {
    allowLocalDeployment = true;
    targetHost = null;
  };

  networking = {
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [ 53317 ]; # LocalSend
      allowedUDPPorts = [ 53317 ]; # LocalSend
    };
  };

  services = {
    dnscrypt-proxy = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;
        sources.public-resolvers = {
          urls = [ "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md" ];
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
      };
    };

    tailscale.enable = true;
  };
}
