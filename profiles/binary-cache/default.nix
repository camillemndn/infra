{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.binary-cache;
in
with lib;

{
  options.profiles.binary-cache = {
    enable = mkEnableOption "Activate my binary cache";
    hostName = mkOption {
      type = types.str;
      example = "cache";
      description = lib.mdDoc ''
        The hostname of the build machine.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      package = pkgs.nix-serve-ng.override {
        nix = pkgs.nixVersions.nix_2_12;
      };
      port = 5001;
      secretKeyFile = "/run/secrets/binary-cache";
    };

    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedGzipSettings = true;

    services.acmeVirtualHosts.${cfg.hostName}.port = 5001;

    # services.nginx.virtualHosts."${cfg.hostName}.${config.services.publicDomain}".acmeRoot = null;

    # security.acme.certs."${cfg.hostName}.${config.services.publicDomain}" = {
    #   server = "https://acme-v02.api.letsencrypt.org/directory";
    #   dnsProvider = "ovh";
    #   dnsResolver = "dns200.anycast.me:53";
    #   dnsPropagationCheck = false;
    #   credentialsFile = "/run/secrets/acme-dns-challenge";
    # };

    sops.secrets = {
      binary-cache = {
        format = "binary";
        sopsFile = ../../secrets + "/${cfg.hostName}-priv-key.pem";
      };
      #acme-dns-challenge = {
      #  format = "binary";
      #  sopsFile = ../../secrets/acme-dns-challenge;
      #};
    };
  };
}
