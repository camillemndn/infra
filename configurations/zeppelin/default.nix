{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "zeppelin";
    hostId = "c5cdb5c5";
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    openssh.enable = true;

    resolved.enable = true;
    tailscale.enable = true;

    filerun.enable = true;

    hammond.enable = true;

    sheetable.enable = true;
    vpnVirtualHosts.sheets = { port = 7777; restricted = false; };

    webtrees.enable = true;
    vpnVirtualHosts.family = { port = 3228; restricted = false; };

    organizr.enable = true;
  };

  profiles = {
    binary-cache = { enable = true; hostName = "cache"; };
    meet.enable = true;
    feeds.enable = true;
    sync.enable = true;
    code-server.enable = true;
    nextcloud.enable = true;
    mail-server.enable = true;
    media-server.enable = true;
    office.enable = true;
    photos.enable = true;
    player.enable = true;
    websites.enable = true;
  };

  system.stateVersion = "21.11";
  system.autoUpgrade.enable = true;
}

