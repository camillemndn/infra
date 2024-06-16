{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.code-server;
in
with lib;

{
  options.profiles.code-server = {
    enable = mkEnableOption "Activate my code server";
  };

  config = mkIf cfg.enable {
    services.openvscode-server = {
      enable = true;
      connectionTokenFile = "/run/secrets/code";
    };

    services.nginx.virtualHosts."code.kms" = {
      port = 4444;
      websockets = true;
    };

    environment.systemPackages = with pkgs; [
      nixpkgs-fmt
      python310
      rWrapper
      rPackages.languageserver
    ];

    sops.secrets.code = {
      format = "binary";
      sopsFile = ./token;
      owner = "code-server";
      group = "code-server";
    };
  };
}
