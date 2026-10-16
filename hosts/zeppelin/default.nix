_:

{
  programs.nixvim.enable = true;

  services = {
    collabora-online.enable = true;
    gramps-web = {
      enable = true;
      hostName = "genealogy.mndn.fr";
    };
    nginx.enable = true;
    webtrees = {
      enable = true;
      hostName = "family.mndn.fr";
    };
  };

  system.stateVersion = "21.11";
}
