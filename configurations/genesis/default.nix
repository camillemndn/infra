{ pkgs, ... }:

{
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
    nix-software-center
  ];

  profiles = {
    gdm = { enable = true; hidpi.enable = true; };
    gnome.enable = true;
    hyprland.enable = true;
    sway.enable = true;
  };

  programs = {
    dconf.enable = true;

    firefox = {
      enable = true;
      languagePacks = [ "fr" ];
      nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
      preferences = {
        "browser.fixup.domainsuffixwhitelist.kms" = true;
        "browser.fixup.domainsuffixwhitelist.luj" = true;
        "browser.fixup.domainsuffixwhitelist.saumon" = true;
      };
      preferencesStatus = "default";
      wrapperConfig.firefox = {
        alsaSupport = true;
        ffmpegSupport = true;
        jackSupport = true;
        pipewireSupport = true;
      };
    };

    steam.enable = true;
  };

  services = {
    logind.killUserProcesses = true;
    openvpn.servers.work = { config = "config /etc/openvpn/work/openvpn_client.ovpn"; autoStart = false; };
    power-profiles-daemon.enable = false;
    printing = { enable = true; drivers = with pkgs; [ brlaser gutenprint ]; };
    tailscale.enable = true;
    tlp.enable = true;
    udev.packages = [ pkgs.android-udev-rules ];
    usbmuxd.enable = true;
  };

  system.stateVersion = "23.05";
}
