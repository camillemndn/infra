{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.spotifyd;
in

{
  config = mkIf cfg.enable {
    services.spotifyd.settings.global = {
      backend = "alsa";
      username_cmd = "cat ${config.age.secrets.spotify-username.path}";
      password_cmd = "cat ${config.age.secrets.spotify-password.path}";
      bitrate = 320;
      volume-normalisation = true;
      normalisation-pregain = -10;
      device_type = "speaker";
      zeroconf_port = 44677;
      use_mpris = false;
      max_cache_size = 500000000;
    };

    services.avahi.enable = true;

    age.secrets = {
      spotify-username.file = ./spotify-username.age;
      spotify-password.file = ./spotify-password.age;
    };

    # Patch
    systemd.services."spotifyd".serviceConfig = {
      DynamicUser = mkForce false;
      SupplementaryGroups = mkForce [
        "audio"
        "pipewire"
      ];
    };

    environment.systemPackages = [ pkgs.spotify-player ];

    networking.firewall.allowedTCPPorts = [ 44677 ];
  };
}
