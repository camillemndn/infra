{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.spotify;
  cfg2 = config.services.spotifyd;
  toml = pkgs.formats.toml { };
  warnConfig =
    if cfg2.config != ""
    then lib.trace "Using the stringly typed .config attribute is discouraged. Use the TOML typed .settings attribute instead."
    else id;
  spotifydConf =
    if cfg2.settings != { }
    then toml.generate "spotify.conf" cfg2.settings
    else warnConfig (pkgs.writeText "spotifyd.conf" cfg2.config);
in

{
  options.profiles.spotify = {
    enable = mkEnableOption "Activate my Spotiy daemon";
  };

  config = mkIf cfg.enable {
    sound.enable = true;

    # hardware.pulseaudio = {
    #   enable = true;
    #   package = pkgs.pulseaudio;
    #   systemWide = true;
    # };
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      systemWide = true;
    };

    services = {
      openssh.enable = true;
      spotifyd = {
        enable = true;
        settings.global = {
          backend = "alsa";
          device_name = "RadioGaGa";
          bitrate = 320;
          volume-normalisation = true;
          normalisation-pregain = -10;
          device_type = "speaker";
          zeroconf_port = 44677;
          use_mpris = false;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 44677 ];
    services.avahi.enable = true;

    # Patch
    systemd.services."spotifyd".serviceConfig = {
      # ExecStart = mkForce "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path ${spotifydConf}";
      DynamicUser = mkForce false;
      SupplementaryGroups = mkForce [ "audio" "pipewire" ];
    };
  };
}
