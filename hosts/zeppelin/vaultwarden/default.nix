_:

{
  services = {
    vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://passwords.kms";
        ROCKET_PORT = "8223";
      };
      environmentFile = "/var/lib/bitwarden_rs/.env";
    };
    nginx.virtualHosts."passwords.kms".port = 8223;
  };

}
