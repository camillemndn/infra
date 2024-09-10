{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "genesis";
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  deployment.allowLocalDeployment = true;

  environment.systemPackages = with pkgs; [
    android-tools
    dump-iphone-backup
    idevicerestore
    ifuse
    libimobiledevice
    libirecovery
    unstable.signalbackup-tools
  ];

  hardware.sane.enable = true;

  programs = {
    firefox.enable = true;
    hyprland.enable = true;
    steam.enable = true;
    sway.enable = true;
  };

  services = {
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

    logind.killUserProcesses = true;
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

    xserver.desktopManager.gnome.enable = true;
    xserver.displayManager.gdm = {
      enable = true;
      hidpi.enable = true;
    };
  };

  system.stateVersion = "23.05";
}
