_:

{
  networking.addresses = {
    ipv4 = {
      public = "77.42.114.11";
      vpn = "100.100.45.7";
    };

    ipv6 = {
      public = "2a01:4f9:3090:2b8c:be24:11ff:fe0b:49fd";
      vpn = "fd7a:115c:a1e0::7";
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
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
