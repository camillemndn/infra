{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.radiogaga;
in
with lib;

{
  options.profiles.radiogaga = {
    enable = mkEnableOption "Activate my radio alarm clock";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 ];

    services.radiogaga.enable = true;

    services.nginx.virtualHosts."radiogaga.local" = {
      default = true;
      forceSSL = mkForce false;
      enableACME = mkForce false;
      root = "${pkgs.radiogaga}/share/radiogaga-front";
      locations."/".tryFiles = "$uri $uri/ /index.html =404";
    };
  };
}
