{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.player;
in

{
  options.profiles.player = {
    enable = mkEnableOption "Activate my Koel player";
  };

  config = mkIf cfg.enable {
    services.koel = {
      enable = true;
      hostName = "player.kms";
      group = "mediasrv";

      extraConfig = {
        MEDIA_PATH = "/srv/media/Musique";
      };
      secretEnvFile = "/run/secrets/player";
    };

    sops.secrets.player = {
      format = "binary";
      sopsFile = ../../secrets/player;
      owner = "koel";
      group = "mediasrv";
    };
  };
}
