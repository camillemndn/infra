{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.code-server;
  code-server-cfg = config.services.code-server;
in
with lib;

{
  options.profiles.code-server = {
    enable = mkEnableOption "Activate my code server";
  };

  config = mkIf cfg.enable {
    services.vpnVirtualHosts.code.port = 4444;

    services.code-server = {
      enable = true;
      package = pkgs.openvscode-server;
    };

    systemd.services.code-server.serviceConfig = {
      ExecStart = mkForce ("${pkgs.openvscode-server}/bin/openvscode-server --host 0.0.0.0 --port ${toString code-server-cfg.port} --connection-token $(cat $CREDENTIALS_DIRECTORY/token) " + escapeShellArgs code-server-cfg.extraArguments);
      LoadCrendential = "token:/run/secrets/code";
    };

    sops.secrets.code = {
      format = "binary";
      sopsFile = ../../secrets/code;
      owner = "code-server";
      group = "code-server";
    };

    services.nginx.virtualHosts."code.${config.services.vpnDomain}".locations."/".proxyWebsockets = true;

    environment.systemPackages = with pkgs; [ nixpkgs-fmt python310 rWrapper rPackages.languageserver ];
  };
}
