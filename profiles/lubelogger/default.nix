{ config, lib, ... }:

lib.mkIf config.services.lubelogger.enable {
  services = {
    lubelogger = {
      settings = {
        UseDarkMode = "true";
        Kestrel__Endpoints__Http__Url = "http://localhost:5003";
      };
    };

    nginx.virtualHosts."vehicles.kms" = {
      port = 5003;
      basicAuthFile = "/var/lib/lubelogger_auth";
    };
  };
}
