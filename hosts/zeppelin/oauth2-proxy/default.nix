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
  services = {
    oauth2-proxy = {
      enable = true;
      provider = "oidc";
      clientID = clientId;
      clientSecretFile = config.age.secrets.oauth2-proxy-client-secret.path;
      oidcIssuerUrl = "https://auth.${cookieDomain}/oauth2/openid/${clientId}";
      reverseProxy = true;
      trustedProxyIP = [
        "127.0.0.1"
        "::1"
      ];
      setXauthrequest = true;
      scope = "openid email profile groups";
      email.domains = [ "*" ];
      cookie = {
        domain = cookieDomain;
        secretFile = config.age.secrets.oauth2-proxy-cookie-secret.path;
        refresh = "1h";
      };
      extraConfig = {
        skip-provider-button = "true";
        whitelist-domain = ".${cookieDomain}";
        code-challenge-method = "S256";
      };
      nginx.domain = ssoDomain;
    };
    # OIDC client and SSO group; nginx enforces each app's allowed_groups.
    kanidm.provision = {
      groups."sso_users" = { };
      systems.oauth2.${clientId} = {
        displayName = "SSO";
        originUrl = "https://${ssoDomain}/oauth2/callback";
        originLanding = "https://${ssoDomain}/";
        basicSecretFile = config.age.secrets.oauth2-proxy-client-secret-for-kanidm.path;
        preferShortUsername = true;
        scopeMaps.sso_users = [
          "openid"
          "email"
          "profile"
          "groups"
        ];
      };
    };
  };

  systemd.services.oauth2-proxy = {
    after = [ "kanidm.service" ];
    wants = [ "kanidm.service" ];
  };
  # email.domains = [ "*" ] admits any Kanidm account: protected vhosts must set allowed_groups.
  assertions = lib.mapAttrsToList (host: vhost: {
    assertion = vhost.allowed_groups != null && vhost.allowed_groups != [ ];
    message = "services.oauth2-proxy.nginx.virtualHosts.\"${host}\" must set allowed_groups; otherwise any Kanidm account can authenticate.";
  }) config.services.oauth2-proxy.nginx.virtualHosts;
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
}
