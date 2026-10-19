{
  config,
  pkgs,
  ...
}:

let
  hostName = "auth.mndn.fr";
  kanidmPort = 8443;
  cert = config.security.acme.certs.${hostName};
in

{
  age.secrets.kanidm-idm-admin-password = {
    file = ./idm-admin-password.age;
    owner = "kanidm";
  };

  security.acme.certs.${hostName} = {
    group = "acme";
    reloadServices = [ "kanidm.service" ];
  };

  services = {
    kanidm = {
      client = {
        enable = true;
        settings.uri = "https://${hostName}";
      };

      package = pkgs.kanidmWithSecretProvisioning_1_11;

      provision = {
        enable = true;
        idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;

        persons.camille = {
          displayName = "Camille";
          mailAddresses = [ "camillemondon@free.fr" ];
        };
      };

      server = {
        enable = true;

        settings = {
          bindaddress = "127.0.0.1:${toString kanidmPort}";
          domain = hostName;

          http_client_address_info."x-forward-for" = [
            "127.0.0.1"
            "::1"
          ];

          origin = "https://${hostName}";
          tls_chain = "${cert.directory}/fullchain.pem";
          tls_key = "${cert.directory}/key.pem";
        };
      };
    };

    nginx.virtualHosts.${hostName} = {
      locations."/" = {
        extraConfig = ''
          proxy_buffer_size       16k;
          proxy_buffers           8 16k;
          proxy_busy_buffers_size 32k;
        '';

        proxyPass = "https://127.0.0.1:${toString kanidmPort}";
      };

      websockets = true;
    };
  };

  users = {
    users = {
      kanidm.extraGroups = [ "acme" ];
      nginx.extraGroups = [ "acme" ];
    };
  };
}
