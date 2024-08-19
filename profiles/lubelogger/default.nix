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
      locations."/".extraConfig = ''
        client_max_body_size               50000M;
        proxy_set_header Host              $http_host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade    $http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_redirect off;
      '';
    };
  };
}
