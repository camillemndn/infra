{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "genesis";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    amdctl
    firefoxpwa
    ifuse
    libimobiledevice
    libirecovery
    idevicerestore
  ];

  profiles = {
    browser.enable = true;
    gdm = {
      enable = true;
      hidpi.enable = true;
    };
    gnome.enable = true;
    hyprland.enable = true;
    sway.enable = true;
  };

  programs.steam.enable = true;

  services = {
    logind.killUserProcesses = true;
    openvpn.servers.work = {
      config = "config /etc/openvpn/work/openvpn_client.ovpn";
      autoStart = false;
    };
    power-profiles-daemon.enable = false;
    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
        gutenprint
      ];
    };
    tailscale.enable = true;
    tlp.enable = true;
    tzupdate.enable = true;
    udev.packages = [ pkgs.android-udev-rules ];
    usbmuxd.enable = true;

    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;
        sources.public-resolvers = {
          urls = [ "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md" ];
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
      };
    };
  };

  system.stateVersion = "23.05";
}
