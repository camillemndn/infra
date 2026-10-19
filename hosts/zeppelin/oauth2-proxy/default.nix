{
  config,
  lib,
  ...
}:

let
  cookieDomain = "mndn.fr";
  ssoDomain = "sso.${cookieDomain}";
  clientId = "oauth2-proxy";
in

{
  age = {
    secrets = {
      oauth2-proxy-client-secret = {
        file = ./oidc-client-secret.age;
        owner = "oauth2-proxy";
      };

      oauth2-proxy-client-secret-for-kanidm = {
        file = ./oidc-client-secret.age;
        owner = "kanidm";
      };

      oauth2-proxy-cookie-secret = {
        file = ./cookie-secret.age;
        owner = "oauth2-proxy";
      };
    };
  };

  # email.domains = [ "*" ] admits any Kanidm account: protected vhosts must set allowed_groups.
  assertions = lib.mapAttrsToList (host: vhost: {
    assertion = vhost.allowed_groups != null && vhost.allowed_groups != [ ];
    message = "services.oauth2-proxy.nginx.virtualHosts.\"${host}\" must set allowed_groups; otherwise any Kanidm account can authenticate.";
  }) config.services.oauth2-proxy.nginx.virtualHosts;

  services = {
    # OIDC client and SSO group; nginx enforces each app's allowed_groups.
    kanidm.provision = {
      groups."sso_users" = { };

      systems.oauth2.${clientId} = {
        basicSecretFile = config.age.secrets.oauth2-proxy-client-secret-for-kanidm.path;
        displayName = "SSO";
        originLanding = "https://${ssoDomain}/";
        originUrl = "https://${ssoDomain}/oauth2/callback";
        preferShortUsername = true;

        scopeMaps.sso_users = [
          "openid"
          "email"
          "profile"
          "groups"
        ];
      };
    };

    oauth2-proxy = {
      enable = true;
      clientID = clientId;
      clientSecretFile = config.age.secrets.oauth2-proxy-client-secret.path;

      cookie = {
        domain = cookieDomain;
        refresh = "1h";
        secretFile = config.age.secrets.oauth2-proxy-cookie-secret.path;
      };

      email.domains = [ "*" ];

      extraConfig = {
        code-challenge-method = "S256";
        skip-provider-button = "true";
        whitelist-domain = ".${cookieDomain}";
      };

      nginx.domain = ssoDomain;
      oidcIssuerUrl = "https://auth.${cookieDomain}/oauth2/openid/${clientId}";
      provider = "oidc";
      reverseProxy = true;
      scope = "openid email profile groups";
      setXauthrequest = true;

      trustedProxyIP = [
        "127.0.0.1"
        "::1"
      ];
    };
  };

  systemd.services.oauth2-proxy = {
    after = [ "kanidm.service" ];
    wants = [ "kanidm.service" ];
  };
}
