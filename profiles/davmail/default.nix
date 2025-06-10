{
  config,
  lib,
  pkgs,
  ...
}:

let
  fqdn = "mail.saumon.network";
in

lib.mkIf config.services.davmail.enable {
  networking.firewall.allowedTCPPorts = [
    443
    1143
    1025
  ];

  services.davmail = {
    config = {
      davmail = {
        allowRemote = true;
        oauth = {
          clientId = "d3590ed6-52b3-4102-aeff-aad2292ab01c";
          redirectUri = "urn:ietf:wg:oauth:2.0:oob";
          persistToken = true;
          tokenFilePath = "/var/lib/davmail/token";
        };
        mode = "O365Manual";
        ssl = {
          keystoreType = "PKCS12";
          keystoreFile = "/var/lib/davmail/davmail.p12";
          keystorePass = "password";
          keyPass = "password";
        };
      };
    };

    url = "https://outlook.office365.com/EWS/Exchange.asmx";
  };

  systemd.services.davmail.serviceConfig = {
    ExecStartPre =
      let
        dir = config.security.acme.certs.${fqdn}.directory;
      in
      "${pkgs.openssl}/bin/openssl pkcs12 -export -in ${dir}/cert.pem -inkey ${dir}/key.pem -certfile ${dir}/chain.pem -out /var/lib/davmail/davmail.p12 -passout pass:password";
    StateDirectory = "davmail";
    SupplementaryGroups = "nginx";
  };

  services.nginx.virtualHosts."${fqdn}" = { };
}
