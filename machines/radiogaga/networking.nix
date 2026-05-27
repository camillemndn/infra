let
  meta = import ./meta.nix;
in
_: {
  deployment = {
    targetHost = meta.ipv4.local;
    buildOnTarget = false;
  };

  networking.networkmanager.enable = true;

  services.openssh.enable = true;
}
