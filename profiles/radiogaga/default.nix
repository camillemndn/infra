{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.radiogaga;
in
with lib;

{
  options.profiles.radiogaga.enable = mkEnableOption "Activate my radio alarm clock";

  config = mkIf cfg.enable {
    services = {
      radiogaga.enable = true;
      nginx.virtualHosts.radiogaga = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 4200;
          }
        ];
        root = "${pkgs.radiogaga}/share/radiogaga-front";
        locations."/".tryFiles = "$uri $uri/ /index.html =404";
        locations."/api".proxyPass = "http://127.0.0.1:8000";
      };

      nginx.virtualHosts."radiogaga.lan".port = 4200;
      nginx.virtualHosts."radiogaga.kms".port = 4200;
    };
  };
}
