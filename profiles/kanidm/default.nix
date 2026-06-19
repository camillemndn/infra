{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostName = "auth.mndn.fr";
  kanidmPort = 8443;
  cert = config.security.acme.certs.${hostName};
in

lib.mkIf config.services.kanidm.server.enable {
  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_10;
    client.enable = true;

    server.settings = {
      domain = hostName;
      origin = "https://${hostName}";
      bindaddress = "127.0.0.1:${toString kanidmPort}";
      tls_chain = "${cert.directory}/fullchain.pem";
      tls_key = "${cert.directory}/key.pem";
      http_client_address_info."x-forward-for" = [
        "127.0.0.1"
        "::1"
      ];
    };

    client.settings.uri = "https://${hostName}";

    provision = {
      enable = true;
      idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;

      persons.camille = {
        displayName = "Camille";
        mailAddresses = [ "camillemondon@free.fr" ];
      };
    };
  };

  users.users.kanidm.extraGroups = [ "acme" ];
  users.users.nginx.extraGroups = [ "acme" ];
  security.acme.certs.${hostName} = {
    group = "acme";
    reloadServices = [ "kanidm.service" ];
  };

  services.nginx.virtualHosts.${hostName} = {
    websockets = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:${toString kanidmPort}";
      extraConfig = ''
        proxy_buffer_size       16k;
        proxy_buffers           8 16k;
        proxy_busy_buffers_size 32k;
      '';
    };
  };

  age.secrets.kanidm-idm-admin-password = {
    file = ./idm-admin-password.age;
    owner = "kanidm";
  };
}
