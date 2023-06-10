{ config, lib, ... }:

with lib;
let
  cfg = config.services;
  virtualHostsEnabled = cfg.virtualHosts != { } || cfg.acmeVirtualHosts != { } || cfg.vpnVirtualHosts != { };

  mapVirtualHosts = f: x: (mapAttrsToList (name: _: f { inherit name; inherit (x.${name}) port; inherit (x.${name}) domain; }) x);
  mapVPNVirtualHosts = g: x: (mapAttrsToList (name: _: g { inherit name; inherit (x.${name}) port; inherit (x.${name}) restricted; inherit (x.${name}) exposedDomain; }) x);

  virtualHostSubModule = types.submodule {
    options = {
      port = mkOption {
        type = types.port;
      };
      domain = mkOption {
        default = cfg.publicDomain;
        type = types.str;
      };
    };
  };

  vpnVirtualHostSubModule = types.submodule {
    options = {
      port = mkOption {
        type = types.port;
      };
      restricted = mkOption {
        default = true;
        type = types.bool;
      };
      exposedDomain = mkOption {
        default = cfg.publicDomain;
        type = types.str;
      };
    };
  };

  mkVirtualHost = { name, port, domain ? cfg.vpnDomain }: {
    "${name}.${domain}" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        extraConfig = ''
          add_header 'Access-Control-Allow-Origin' 'https://${cfg.corsDomain}';
          add_header 'Access-Control-Allow-Credentials' true;
        '';
      };
    };

    "www.${name}.${domain}" = {
      globalRedirect = "${name}.${domain}";
    };
  };

  mkACMEVirtualHost = { name, port, domain }: mkMerge [
    (mkVirtualHost { inherit name; inherit port; inherit domain; })
    {
      "${name}.${domain}" = {
        forceSSL = true;
        enableACME = true;
      };

      "www.${name}.${domain}" = {
        useACMEHost = "${name}.${domain}";
        forceSSL = true;
      };
    }
  ];

  mkVPNVirtualHost = { name, port, restricted, exposedDomain }: mkMerge [
    (mkACMEVirtualHost { inherit name; inherit port; domain = "kms"; })
    {
      "${name}.${cfg.vpnDomain}".locations."/".extraConfig = ''
        allow 100.100.45.0/24;
        allow fd7a:115c:a1e0::/48;
        deny all;
      '';
    }
    (mkIf (!restricted) (mkACMEVirtualHost { inherit name; inherit port; domain = exposedDomain; }))
  ];
in

{
  options.services = {
    publicDomain = mkOption {
      default = "mondon.xyz";
      type = types.str;
    };
    vpnDomain = mkOption {
      default = "kms";
      type = types.str;
    };
    corsDomain = mkOption {
      default = "home.kms";
      type = types.str;
    };
    acmeServer = mkOption {
      default = "https://ca.luj:8444/acme/acme/directory";
      type = types.str;
    };
    virtualHosts = mkOption {
      default = { };
      type = types.attrsOf virtualHostSubModule;
    };
    acmeVirtualHosts = mkOption {
      default = { };
      type = types.attrsOf virtualHostSubModule;
    };
    vpnVirtualHosts = mkOption {
      default = { };
      type = types.attrsOf vpnVirtualHostSubModule;
    };
  };

  config =
    {
      services.nginx = {
        enable = mkIf virtualHostsEnabled true;
        recommendedOptimisation = mkDefault true;
        recommendedProxySettings = mkDefault true;
        recommendedGzipSettings = mkDefault true;
        recommendedTlsSettings = mkDefault true;

        virtualHosts = mkMerge (
          (mapVirtualHosts mkVirtualHost cfg.virtualHosts)
          ++
          (mapVirtualHosts mkACMEVirtualHost cfg.acmeVirtualHosts)
          ++
          (mapVPNVirtualHosts mkVPNVirtualHost cfg.vpnVirtualHosts)
        );
      };

      # Use VPN CA only on .kms domains
      security.acme.certs = mapAttrs
        (n: _v: mkIf (hasSuffix ".kms" n && (!hasPrefix "www." n)) { server = cfg.acmeServer; })
        config.services.nginx.virtualHosts;

      networking.firewall.allowedTCPPorts = mkIf virtualHostsEnabled [ 443 ];
    };
}
