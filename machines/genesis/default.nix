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

  deployment = {
    allowLocalDeployment = true;
    targetHost = null;
  };

  environment = {
    systemPackages = with pkgs; [
      android-tools
      dump-iphone-backup
      idevicerestore
      ifuse
      libimobiledevice
      libirecovery
      signalbackup-tools
    ];
  };

  hardware.sane = {
    enable = true;
    dsseries.enable = true;
  };

  programs = {
    firefox.enable = true;
    nixvim.enable = true;
    steam.enable = true;
    sway.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    dnscrypt-proxy = {
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

    fwupd.enable = true;

    logind.settings.Login = {
      KillUserProcesses = true;
      HandleLidSwitch = "suspend-then-hibernate";
    };

    power-profiles-daemon.enable = false;

    printing = {
      enable = true;
      drivers = with pkgs; [
        cups-brother-hll2340dw
        samsung-unified-linux-driver
      ];
    };

    tailscale.enable = true;
    tlp.enable = true;
    tzupdate.enable = true;
    usbmuxd.enable = true;
  };

  stylix.enable = true;

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  system.stateVersion = "23.05";
}
