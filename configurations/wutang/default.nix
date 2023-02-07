{ config, pkgs, ... }:

{
  networking.hostName = "wutang";
  wsl.defaultUser = "camille";

  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  system.stateVersion = "22.11";
}
