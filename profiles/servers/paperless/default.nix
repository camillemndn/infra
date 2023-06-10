{ config, lib, ... }:

let
  cfg = config.profiles.paperless;
in
with lib;

{
  options.profiles.paperless = {
    enable = mkEnableOption "Paperless-ngx";
    hostName = mkOption {
      type = types.str;
      default = "docs.kms";
    };
  };

  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      extraConfig = {
        PAPERLESS_ADMIN_USER = "Camille";
        PAPERLESS_OCR_MODE = "skip_noarchive";
      };
    };

    services.vpnVirtualHosts.docs.port = 28981;
  };
}
