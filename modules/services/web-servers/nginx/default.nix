{ config, lib, ... }:

let
  cfg = config.services.nginx;
in
with lib;

{
  options.services.nginx = {
    noDefault.enable = mkEnableOption (mdDoc ''Don't fallback to default page'');

    publicDomains = mkOption {
      default = [ "mondon.xyz" "saumon.network" "yali.es" ];
      type = types.listOf types.str;
    };

    vpnDomains = mkOption {
      default = [ ".kms" ];
      type = types.listOf types.str;
    };

    vpnAcmeServer = mkOption {
      default = "https://ca.luj/acme/acme/directory";
      type = types.str;
    };

    localDomains = mkOption {
      default = [ ".lan" ".local" ];
      type = types.listOf types.str;
    };

    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule ({ name, config, publicDomains, ... }: {
        options.port = mkOption { type = types.port; default = 0; };
        options.websockets = mkOption { type = types.bool; default = false; };

        config = {
          forceSSL = mkDefault (hasInfix "." name && !hasSuffixIn cfg.localDomains name);
          enableACME = mkDefault config.forceSSL;
          locations."/" = {
            proxyPass = let p = config.port; in mkIf (p != 0) (mkDefault "http://127.0.0.1:${toString p}");
            proxyWebsockets = mkDefault config.websockets;
          };
          # Firewall VPN domains
          extraConfig =
            if (hasSuffixIn cfg.publicDomains name) then ''
              allow all; 
            '' else '' 
              if ($bad_ip) {
                return 444;
              }
              ssl_stapling off;
            '';
        };
      }));
    };
  };

  config = {
    services.nginx = {
      # Enable when some virtual hosts are declared
      enable = filter (hasInfix ".") (attrNames cfg.virtualHosts) != [ ];

      recommendedOptimisation = mkDefault true;
      recommendedProxySettings = mkDefault true;
      recommendedGzipSettings = mkDefault true;
      recommendedTlsSettings = mkDefault true;

      # VPN IPs
      appendHttpConfig = ''
        geo $bad_ip {
        default 1;
        127.0.0.1/32 0;
        ::1/128 0;
        192.168.0.0/16 0;
        fc00::/7 0;
        100.100.45.0/24 0;
        fd7a:115c:a1e0::/48 0;
        }
        
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
          return 444;
        '';
      };
    };

    # Use VPN CA only on VPN domains
    security.acme.certs = mapAttrs
      (n: _: mkIf
        (config.services.tailscale.enable && hasSuffixIn cfg.vpnDomains n && !hasPrefix "www." n)
        { server = mkDefault cfg.vpnAcmeServer; })
      cfg.virtualHosts;

    # Open port 443 only if necessary
    networking.firewall.allowedTCPPorts = mkIf cfg.enable [ 80 443 ];
    networking.firewall.allowedUDPPorts = mkIf cfg.enable [ 80 443 ];
  };
}
