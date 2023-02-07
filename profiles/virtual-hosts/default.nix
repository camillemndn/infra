{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services;

  mapVirtualHosts = f: x: (mapAttrsToList (name: value: f { name = name; port = x.${name}.port; domain = x.${name}.domain; }) x);
  mapVPNVirtualHosts = g: x: (mapAttrsToList (name: value: g { name = name; port = x.${name}.port; restricted = x.${name}.restricted; exposedDomain = x.${name}.exposedDomain; }) x);

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
    (mkVirtualHost { name = name; port = port; domain = domain; })
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
    (mkACMEVirtualHost { name = name; port = port; domain = "kms"; })
    {
      "${name}.${cfg.vpnDomain}".locations."/".extraConfig = ''
        allow 100.10.10.0/8;
        deny all;
      '';
    }
    (mkIf (!restricted) (mkVirtualHost { name = name; port = port; domain = exposedDomain; }))
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

  config = #let service = mapAttrs' (x:v: nameValuePair (v.service) {enable = true;}) config.services.vpnVirtualHosts; in 
    {
      services.nginx = {
        enable = mkIf (cfg.virtualHosts != { } || cfg.acmeVirtualHosts != { } || cfg.vpnVirtualHosts != { }) true;
        recommendedProxySettings = true;

        virtualHosts = mkMerge (
          #foldl recursiveUpdate {} <==> mkMerge 
          (mapVirtualHosts mkVirtualHost cfg.virtualHosts)
          ++
          (mapVirtualHosts mkACMEVirtualHost cfg.acmeVirtualHosts)
          ++
          (mapVPNVirtualHosts mkVPNVirtualHost cfg.vpnVirtualHosts)
        );
      };

      security.acme.defaults.server = cfg.acmeServer;
      networking.firewall.allowedTCPPorts = [ 80 443 ];
    };
}
