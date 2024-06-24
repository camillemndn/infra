{ config, lib, ... }:

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
      description = ''The hostname of the build machine.'';
    };
  };

  config = mkIf cfg.enable {
    services.nix-serve = {
      enable = true;
      port = 5001;
      secretKeyFile = "/run/secrets/binary-cache";
    };

    services.nginx.virtualHosts.${cfg.hostName}.port = 5001;

    sops.secrets.binary-cache = {
      format = "binary";
      sopsFile = ./${cfg.hostName}.pem;
    };
  };
}
