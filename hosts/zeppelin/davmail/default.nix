{
  config,
  pkgs,
  ...
}:

let
  fqdn = "bridge.mndn.fr";
in

{
  networking.firewall.allowedTCPPorts = [
    443
    1143
    1025
  ];

  services = {
    davmail = {
      enable = true;

      config = {
        davmail = {
          allowRemote = true;
          mode = "O365DeviceCode";

          oauth = {
            clientId = "d3590ed6-52b3-4102-aeff-aad2292ab01c";
            persistToken = true;
            redirectUri = "urn:ietf:wg:oauth:2.0:oob";
            tokenFilePath = "/var/lib/davmail/token";
          };

          ssl = {
            keyPass = "password";
            keystoreFile = "/var/lib/davmail/davmail.p12";
            keystorePass = "password";
            keystoreType = "PKCS12";
          };
        };
      };

      url = "https://outlook.office365.com/EWS/Exchange.asmx";
    };

    nginx.virtualHosts."${fqdn}" = { };
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
}
