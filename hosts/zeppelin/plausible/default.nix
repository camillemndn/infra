{ config, ... }:

{
  age.secrets.plausible-secret-key-base.file = ./secret-key-base.age;

  services = {
    nginx.virtualHosts."analytics.mndn.fr".port = config.services.plausible.server.port;

    plausible = {
      enable = true;

      server = {
        baseUrl = "https://analytics.mndn.fr";
        secretKeybaseFile = config.age.secrets.plausible-secret-key-base.path;
      };
    };
  };
}
