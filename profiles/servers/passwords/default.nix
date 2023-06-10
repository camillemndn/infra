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
        #ROCKET_ADDRESS = "127.0.0.1";
      };
      environmentFile = "/var/lib/bitwarden_rs/.env";
    };

    services.vpnVirtualHosts.passwords.port = 8223;
  };
}
