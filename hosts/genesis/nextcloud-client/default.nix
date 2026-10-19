{ pkgs, ... }:

{
  home-manager.users.camille = {
    services.nextcloud-client = {
      enable = true;
      package = pkgs.unstable.nextcloud-client;
      startInBackground = true;
    };

    systemd.user.services.nextcloud-client.Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/rm -rf %h/.local/share/Nextcloud";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
