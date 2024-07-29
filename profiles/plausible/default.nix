{ config, lib, ... }:

lib.mkIf config.services.plausible.enable {
  services.plausible = {
    adminUser = {
      activate = true;
      email = "camillemondon@online.fr";
      passwordFile = config.age.secrets.plausible-admin-password.path;
    };
    server = {
      baseUrl = "https://analytics.mondon.xyz";
      secretKeybaseFile = config.age.secrets.plausible-secret-key-base.path;
    };
  };

  services.nginx.virtualHosts."analytics.mondon.xyz".port = config.services.plausible.server.port;

  age.secrets = {
    plausible-admin-password.file = ./admin-password.age;
    plausible-secret-key-base.file = ./secret-key-base.age;
  };
}