{ config, lib, ... }:

{
  config = lib.mkIf (config.networking.wireless.enable == true) {
    networking.wireless = {
      networks."K-Barôcrane".psk = "@K_BAROCRANE@";
      networks."K-1000_mobile".psk = "@K_1000_MOBILE@";
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
