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
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    layout = "fr";
    xkbVariant = "";
  };

  services.printing.enable = true;

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
    gnome.dconf-editor
    nix-software-center
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
  };

  sops.age.keyFile = "/home/camille/.config/sops/age/keys.txt";

  system.stateVersion = "23.05";
}
