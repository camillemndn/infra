{ config, lib, ... }:

lib.mkIf config.services.vaultwarden.enable {
  services.vaultwarden = {
    config = {
      DOMAIN = "https://passwords.kms";
      ROCKET_PORT = "8223";
    };
    environmentFile = "/var/lib/bitwarden_rs/.env";
  };

  services.nginx.virtualHosts."passwords.kms".port = 8223;
}
