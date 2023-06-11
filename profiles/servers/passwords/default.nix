{ config, lib, ... }:

let
  cfg = config.profiles.passwords;
in
with lib;

{
  options.profiles.passwords = {
    enable = mkEnableOption "Passwords";
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://passwords.kms";
        ROCKET_PORT = "8223";
      };
      environmentFile = "/var/lib/bitwarden_rs/.env";
    };

    services.nginx.virtualHosts."passwords.kms".port = 8223;
  };
}
