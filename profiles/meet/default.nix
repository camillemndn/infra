{ config, lib, ... }:

let
  cfg = config.profiles.meet;
in
with lib;

{
  options.profiles.meet = {
    enable = mkEnableOption "Jitsi";
    hostName = mkOption {
      type = types.str;
      default = "meet.kms";
    };
  };

  config = mkIf cfg.enable {
    services.jitsi-meet = {
      enable = true;
      hostName = cfg.hostName;
      nginx.enable = true;
      prosody.enable = true;
      videobridge.enable = true;
      jicofo.enable = true;
      config.hosts.anonymousdomain = "guest.${cfg.hostName}";
    };

    services.jitsi-videobridge = {
      openFirewall = true;
      nat = {
        publicAddress = "78.194.168.230";
        localAddress = "192.168.1.137";
      };
    };

    services.prosody.virtualHosts = {
      ${cfg.hostName} = mkForce {
        enabled = true;
        domain = cfg.hostName;
        extraConfig = ''
          authentication = "internal_hashed"
          c2s_require_encryption = false
          admins = { "focus@auth.${cfg.hostName}" }
          smacks_max_unacked_stanzas = 5
          smacks_hibernation_time = 60
          smacks_max_hibernated_sessions = 1
          smacks_max_old_sessions = 1
        '';
      };
      "guest.${cfg.hostName}" = {
        enabled = true;
        domain = "guest.${cfg.hostName}";
        extraConfig = ''
          authentication = "anonymous"
          c2s_require_encryption = false
        '';
      };
    };

    services.jicofo = {
      config = {
        jicofo = {
          authentication = {
            enabled = "true";
            type = "XMPP";
            login-url = "meet.mondon.xyz";
          };
          xmpp.client.client-proxy = "focus.${cfg.hostName}";
        };
      };
    };

    services.nginx.virtualHosts."${cfg.hostName}" = {
      enableACME = false;
      forceSSL = false;
    };

    # networking.firewall.allowedUDPPorts = [ 10000 ];
  };
}

