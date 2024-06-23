{ config, lib, ... }:

let
  cfg = config.profiles.office;
in
with lib;

{
  options.profiles.office = {
    enable = mkEnableOption "Only Office";
    hostName = mkOption {
      type = types.str;
      default = "office.kms";
    };
  };

  config = mkIf cfg.enable {
    services.onlyoffice = {
      enable = true;
      enableExampleServer = true;
      examplePort = 8001;
    };

    services.nginx.virtualHosts."office.kms".port = 8000;
  };
}
