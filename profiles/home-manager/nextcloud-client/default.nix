{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.nextcloud-client.enable {
  services.nextcloud-client = {
    package = pkgs.unstable.nextcloud-client;
    startInBackground = true;
  };

  systemd.user.services.nextcloud-client.Service = {
    ExecStartPre = "${pkgs.coreutils}/bin/rm -rf %h/.local/share/Nextcloud";
    Restart = "on-failure";
    RestartSec = "5s";
  };
}
