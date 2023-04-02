{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.nextcloud;
in
with lib;

{
  options.profiles.nextcloud = {
    enable = mkEnableOption "Activate my Nextcloud instance";
  };

  config = mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud26;
      hostName = "social.kms";
      config.adminpassFile = "/run/secrets/nextcloud";
      enableBrokenCiphersForSSE = false;
    };

    sops.secrets.nextcloud = {
      format = "binary";
      sopsFile = ../../secrets/nextcloud;
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nginx.virtualHosts."social.kms" = { enableACME = true; forceSSL = true; };
  };
}
