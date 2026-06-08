{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  programs.nixvim.enable = true;

  services = {
    buildbot-nix.master.enable = true;
    collabora-online.enable = true;
    davmail.enable = true;
    firefly-iii.enable = true;
    immich.enable = true;
    jellyfin.enable = true;
    minecraft-server.enable = true;
    nextcloud.enable = true;
    nginx = {
      enable = true;
      websites = {
        "camillemondon.com".enable = true;
        "ceciliaflamenca.com".enable = true;
        "natachamondonericpierre.fr".enable = true;
        "varanda.fr".enable = true;
        "yali.es".enable = true;
      };
    };
    photoprism.enable = true;
    plausible.enable = true;
    tandoor-recipes.enable = true;
    vaultwarden.enable = true;
    webtrees = {
      enable = true;
      hostName = "family.mndn.fr";
    };
    webhook.enable = true;
  };

  system.stateVersion = "21.11";
}
