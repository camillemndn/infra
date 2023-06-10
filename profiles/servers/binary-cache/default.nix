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
      description = lib.mdDoc ''The hostname of the build machine.'';
    };
  };

  config = mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      package = pkgs.nix-serve-ng.override { nix = pkgs.nixVersions.nix_2_12; };
      port = 5001;
      secretKeyFile = "/run/secrets/binary-cache";
    };

    services.acmeVirtualHosts.${cfg.hostName}.port = 5001;
    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedGzipSettings = true;

    sops.secrets.binary-cache = {
      format = "binary";
      sopsFile = ./${cfg.hostName}-priv-key.pem;
    };
  };
}
