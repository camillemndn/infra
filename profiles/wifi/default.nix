{ config, lib, ... }:

{
  config = lib.mkIf (config.networking.wireless.enable == true) {
    networking.wireless = {
      networks."K-Barôcrane".psk = "@K_BAROCRANE@";
      networks."K-1000_mobile".psk = "@K_1000_MOBILE@";
      networks."Is There Anybody Out There?".psk = "@IS_THERE_ANYBODY_OUT_THERE@";
      environmentFile = "/run/secrets/wifi";
      extraConfig = ''
        update_config=1
        country=FR
      '';
    };

    sops.secrets.wifi = {
      format = "binary";
      sopsFile = ../../secrets/wifi;
    };
  };
}
