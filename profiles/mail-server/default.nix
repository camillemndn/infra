{ config, lib, pkgs, ... }:

let
  mailDomain = "saumon.network";
  sogoDomain = "people.kms";
  cfg = config.profiles.mail-server;
in
with lib;

{
  options.profiles.mail-server = {
    enable = mkEnableOption "Mail server";
    sogo.enable = mkEnableOption "SoGo groupware";
  };

  config = mkIf cfg.enable {
    mailserver = {
      enable = true;
      enableManageSieve = true;
      fqdn = "mail.${mailDomain}";
      domains = [ "${mailDomain}" "mondon.me" "braithwaite.fr" ];
      loginAccounts = {
        # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
        "camille@mondon.me" = {
          hashedPasswordFile = "/run/secrets/mail-server/mondon.me/camille";
          aliases = [ "@mondon.me" ];
        };
        "emma@braithwaite.fr" = {
          hashedPasswordFile = "/run/secrets/mail-server/braithwaite.fr/emma";
          aliases = [ "@braitwaite.fr" ];
        };
        "verso@saumon.network" = {
          hashedPasswordFile = "/run/secrets/mail-server/saumon.network/verso";
        };
      };
      localDnsResolver = false;
      certificateScheme = "acme-nginx";
    };

    services.roundcube = {
      enable = true;
      # this is the url of the vhost, not necessarily the same as the fqdn of
      # the mailserver
      hostName = "webmail.${mailDomain}";
      plugins = [ "archive" "managesieve" ];
      extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
    };

    # services.nginx.virtualHosts."webmail.${mailDomain}" = {
    #   forceSSL = mkForce false;
    #   enableACME = mkForce false;
    # };

    services.fail2ban = {
      enable = true;

      package = pkgs.fail2ban.overrideAttrs (final: prev: {
        preConfigure = prev.preConfigure + ''
          for i in config/action.d/nftable*.conf; do
            substituteInPlace $i \
              --replace "type <addr_type>\;" "type <addr_type>\; flags interval\;"
          done
        '';
      });

      ignoreIP = [
        "192.168.0.0/16"
        "100.100.45.0/24"
      ];

      jails = {
        postfix = ''
          enabled = true
          mode = extra
        '';
        dovecot = ''
          # block IPs which failed to log-in
          # aggressive mode add blocking for aborted connections
          enabled = true
          filter = dovecot[mode=aggressive]
          maxretry = 3
        '';
      };
      bantime = "-1";
    };

    services.sogo = mkIf cfg.sogo.enable {
      enable = true;
      timezone = "Europe/Paris";
      language = "French";
      vhostName = sogoDomain;
      extraConfig = ''
        SOGoMailDomain = "${mailDomain}";
          SOGoIMAPServer = "imaps://mail.${mailDomain}:993";
          SOGoMailingMechanism = "smtp";
          SOGoSMTPServer = "smtps://mail.${mailDomain}:465";
          SOGoUserSources = ({
            canAuthenticate = YES;
            displayName = "SOGo Users";
            id = "users";
            isAddressBook = YES;
            type = sql;
            userPasswordAlgorithm = md5;
              viewURL = "mysql://sogo:@%2Frun%2Fmysqld%2Fmysqld.sock/sogo/sogo_users";
          });
          SOGoProfileURL = "mysql://sogo:@%2Frun%2Fmysqld%2Fmysqld.sock/sogo/sogo_user_profile";
          OCSFolderInfoURL = "mysql://sogo:@%2Frun%2Fmysqld%2Fmysqld.sock/sogo/sogo_folder_info";
          OCSSessionsFolderURL = "mysql://sogo:@%2Frun%2Fmysqld%2Fmysqld.sock/sogo/sogo_sessions_folder";
          SOGoVacationEnabled = YES;
          SOGoMailMessageCheck = "every_5_minutes";
          SOGoFirstDayOfWeek = 1;
          SOGoLoginModule = "Calendar";
          SOGoSuperUsernames = ( "admin" );
          SOGoMemcachedHost = 127.0.0.1;
          NGImap4ConnectionStringSeparator = ".";
      '';
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."${sogoDomain}" = mkIf cfg.sogo.enable {
      forceSSL = true;
      enableACME = true;
      locations."^~/SOGo".extraConfig = mkForce ''
        proxy_pass http://127.0.0.1:20000;
        proxy_redirect http://127.0.0.1:20000 default;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header x-webobjects-server-protocol HTTP/1.0;
        proxy_set_header x-webobjects-remote-host 127.0.0.1;
        proxy_set_header x-webobjects-server-port $server_port;
        proxy_set_header x-webobjects-server-name $server_name;
        proxy_set_header x-webobjects-server-url $scheme://$host;
        proxy_connect_timeout 90;
        proxy_send_timeout 3650;
        proxy_read_timeout 3650;
        proxy_buffer_size 128k;
        proxy_buffers 64 512k;
        proxy_busy_buffers_size 512k;
        proxy_temp_file_write_size 512k;
        client_max_body_size 0;
        client_body_buffer_size 512k;
        break;
      '';
    };

    services.memcached.enable = mkIf cfg.sogo.enable true;
    services.mysql = mkIf cfg.sogo.enable {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureUsers = [{
        name = "sogo";
        ensurePermissions = {
          "sogo.*" = "ALL PRIVILEGES";
        };
      }];
      ensureDatabases = [ "sogo" ];
    };

    # services.nginx.virtualHosts."mail.${mailDomain}".acmeRoot = mkForce null;
    # security.acme.certs."mail.${mailDomain}" = {
    #   server = "https://acme-v02.api.letsencrypt.org/directory";
    #   dnsProvider = "ovh";
    #   dnsResolver = "dns200.anycast.me:53";
    #   dnsPropagationCheck = false;
    #   credentialsFile = "/run/secrets/acme-dns-challenge";
    # };

    sops.secrets = {
      "mail-server/mondon.me/camille" = {
        format = "yaml";
        key = "camille-mondon-me";
        sopsFile = ../../secrets/mail-server.yaml;
      };
      "mail-server/braithwaite.fr/emma" = {
        format = "yaml";
        key = "emma-braithwaite-fr";
        sopsFile = ../../secrets/mail-server.yaml;
      };
      "mail-server/saumon.network/verso" = {
        format = "yaml";
        key = "verso-saumon-network";
        sopsFile = ../../secrets/mail-server.yaml;
      };
      # acme-dns-challenge = {
      #   format = "binary";
      #   sopsFile = ../../secrets/acme-dns-challenge;
      # };
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
