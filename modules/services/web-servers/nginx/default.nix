{ config, lib, ... }:

with lib;
let
  cfg = config.services.nginx;

  mergeSub = f: mkMerge (map (sub: f (sub.systemConfig systemArgs)) (attrValues cfg.virtualHosts));

  recordsFromDomain =
    domain:
    mapAttrs' (
      n: v:
      nameValuePair (dns.domainToZone dns.allowedDomains n) (
        let
          subdomain = dns.getDomainPrefix dns.allowedDomains n;
        in
        if elem subdomain dns.allowedDomains then v else { subdomains."${subdomain}" = v; }
      )
    ) (dns.domainToRecords domain config.machine.meta (dns.isVPNDomain domain));
in

{
  options.services.nginx = {
    localDomains = mkOption {
      default = [
        ".lan"
        ".local"
      ];
      type = types.listOf types.str;
    };

    noDefault.enable = mkEnableOption ''Don't fallback to default page'';

    publicDomains = mkOption { type = types.listOf types.str; };

    vpnAcmeServer = mkOption { type = types.str; };

    vpnDomains = mkOption { type = types.listOf types.str; };

    virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule (
          {
            name,
            config,
            ...
          }:
          {
            options = {
              port = mkOption {
                type = types.port;
                default = 0;
              };
              websockets = mkOption {
                type = types.bool;
                default = false;
              };
              systemConfig = mkOption {
                internal = true;
                type = types.unspecified; # A function from module arguments to config.
              };
            };

            config = {
              forceSSL = mkDefault (hasInfix "." name && !hasSuffixIn cfg.localDomains name);
              enableACME = mkDefault config.forceSSL;
              locations."/" = {
                proxyPass =
                  let
                    p = config.port;
                  in
                  mkIf (p != 0) (mkDefault "http://127.0.0.1:${toString p}");

                proxyWebsockets = mkDefault config.websockets;

                # Firewall VPN domains
                extraConfig = mkIf (hasSuffixIn cfg.vpnDomains name) ''
                  allow 100.100.45.0/24;
                  allow fd7a:115c:a1e0::/48;
                  deny all;
                '';
              };

              extraConfig = mkIf (hasSuffixIn cfg.vpnDomains name) ''
                ssl_stapling off;
              '';

              systemConfig = _: {
                machine.meta.zones = optionalAttrs (name != "default") (recordsFromDomain name);

                security.acme.certs = optionalAttrs (hasSuffixIn cfg.vpnDomains name) {
                  "${name}".server = mkIf (hasSuffixIn cfg.vpnDomains name) cfg.vpnAcmeServer;
                };
              };
            };
          }
        )
      );
    };
  };

  config = {
    services.nginx = mkIf cfg.enable {
      recommendedOptimisation = mkDefault true;
      recommendedProxySettings = mkDefault true;
      recommendedGzipSettings = mkDefault true;
      recommendedTlsSettings = mkDefault true;

      appendHttpConfig = ''
        proxy_headers_hash_max_size 512;
        proxy_headers_hash_bucket_size 128;
      '';

      clientMaxBodySize = "20m";

      # Do not fallback to default
      virtualHosts.default = mkIf cfg.noDefault.enable {
        default = true;
        addSSL = true;
        # To generate the certificates: nix run nixpkgs#openssl -- req -newkey rsa:4096 -x509 -sha256 -nodes -out cert.pem -keyout key.pem
        sslCertificate = "/var/lib/acme/default/cert.pem";
        sslCertificateKey = "/var/lib/acme/default/key.pem";
        extraConfig = ''
          ssl_stapling off;
          return 444;
        '';
      };
    };

    machine = mergeSub (c: c.machine);
    security.acme.certs = mergeSub (c: c.security.acme.certs);

    # Open port 443 only if necessary
    networking.firewall.allowedTCPPorts = mkIf cfg.enable [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = mkIf cfg.enable [
      80
      443
    ];
  };
}
