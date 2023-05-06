{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "zeppelin";
    hostId = "c5cdb5c5";
    firewall.allowedTCPPorts = [ 2022 ];
  };

  services = {
    hammond.enable = true;
    openssh.enable = true;
    resolved.enable = true;
    sheetable.enable = true;
    vpnVirtualHosts.sheets = { port = 7777; restricted = false; };
    tailscale.enable = true;
    webtrees.enable = true;
    vpnVirtualHosts.family = { port = 3228; restricted = false; };
  };

  profiles = {
    binary-cache = { enable = true; hostName = "cache"; };
    cloud.enable = true;
    code-server.enable = true;
    feeds.enable = true;
    mail-server.enable = true;
    media-server.enable = true;
    meet = { enable = true; hostName = "meet.mondon.xyz"; };
    office.enable = true;
    paperless.enable = true;
    passwords.enable = true;
    photos.enable = true;
    player.enable = true;
    sync.enable = true;
    websites.enable = true;
  };

  system.stateVersion = "21.11";
}

