{ config, pkgs, ... }:

{
  networking = {
    hostName = "genesis";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Paris";
  console.keyMap = "fr";
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      wayland = true;
      enable = true;
      extraConfig = ''
        [org/gnome/desktop/interface]
        cursor-size=40
        text-scaling-factor=1.5
        scaling-factor=2
        show-battery-percentage=true
      '';
    };
    displayManager.setupCommands = ''
      xrandr --setprovideroutputsource modesetting NVIDIA-0
      xrandr --auto
    '';
    desktopManager.gnome.enable = true;

    layout = "fr";
    xkbVariant = "";
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  qt.enable = true;
  qt.style = "adwaita-dark";
  qt.platformTheme = "gnome";

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Ubuntu" ]; })
  ];

  environment.systemPackages = with pkgs; with gnomeExtensions; [
    tailscale-status
    screen-rotate
    nextcloud-folder
    blur-my-shell
    recent-items
    supergfxctl-gex
    wireless-hid
    vitals
    no-activities-button
    custom-hot-corners-extended
    hide-universal-access
    arrange-windows
    window-state-manager
    # tray-icons-reloaded
    appindicator
    miniview
    gnome.dconf-editor
    nix-software-center
  ];

  environment.variables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";

  nixpkgs.overlays = [
    (final: prev: {
      firefox = prev.firefox.override { cfg.enableFirefoxPwa = true; };
    })
  ];

  programs = {
    firefox.enable = true;
    steam.enable = true;
    dconf.enable = true;
  };

  services = {
    tailscale.enable = true;
    power-profiles-daemon.enable = false;
    tlp.enable = true;
    logind.killUserProcesses = true;
  };

  sops.age.keyFile = "/home/camille/.config/sops/age/keys.txt";

  system.stateVersion = "23.05";
}
