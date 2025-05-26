{ config, lib, ... }:

lib.mkIf config.services.plausible.enable {
  services.plausible.server = {
    baseUrl = "https://analytics.mondon.xyz";
    secretKeybaseFile = config.age.secrets.plausible-secret-key-base.path;
  };

  services.nginx.virtualHosts."analytics.mondon.xyz".port = config.services.plausible.server.port;

  age.secrets.plausible-secret-key-base.file = ./secret-key-base.age;
}
