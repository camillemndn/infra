{
  config,
  lib,
  pkgs,
  ...
}:

let
  fqdn = "bridge.saumon.network";
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
        # EWS for Exchange Online retires 2026-10-01; use the Graph backend.
        # davmail >= 6.8 splits protocol (mode) from auth (authentication).
        mode = "O365Graph";
        # Headless device-code flow: davmail logs a microsoft.com/devicelogin
        # URL + code on first connect; approve it from any browser.
        authentication = "O365DeviceCode";
        oauth = {
          # First-party Office app: pre-consented in every tenant, so no admin
          # action needed (same reason EWS worked). Do NOT drop this.
          clientId = "d3590ed6-52b3-4102-aeff-aad2292ab01c";
          persistToken = true;
          tokenFilePath = "/var/lib/davmail/token";
        };
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

  services.nginx = {
    publicDomains = [ "saumon.network" ];
    virtualHosts."${fqdn}" = { };
  };
}
