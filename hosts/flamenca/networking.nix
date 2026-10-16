_: {
  networking = {
    networkmanager.enable = true;
  };

  deployment = {
    targetHost = null;
    allowLocalDeployment = true;
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };
}
