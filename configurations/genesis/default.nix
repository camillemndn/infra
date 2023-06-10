{ config, pkgs, ... }:

{
  networking = {
    hostName = "genesis";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nix-software-center
    amdctl
  ];

  nixpkgs.config.firefox = {
    ffmpegSupport = true;
    enableGnomeExtensions = true;
    enableFirefoxPwa = true;
  };

  nixpkgs.overlays = [
    (_final: prev: {
      thunderbird-bin-unwrapped = prev.thunderbird-bin-unwrapped.overrideAttrs (_old:
        let version = "115.0a1"; in {
          inherit version;
          src = pkgs.fetchurl {
            url = "https://ftp.mozilla.org/pub/thunderbird/nightly/latest-comm-central-l10n/thunderbird-${version}.fr.linux-x86_64.tar.bz2";
            sha256 = "sha256-lPwtgerS1rheSJoMuQUx1RoYNikJoDuc19gE8od3q50=";
          };
        });

    })
  ];

  profiles = {
    gdm.enable = true;
    gnome.enable = true;
    hyprland.enable = true;
  };

  programs = {
    firefox.enable = true;
    steam.enable = true;
    dconf.enable = true;
  };

  services = {
    logind.killUserProcesses = true;
    power-profiles-daemon.enable = false;
    printing = { enable = true; drivers = [ pkgs.brlaser ]; };
    tailscale.enable = true;
    tlp.enable = true;
    udev.packages = [ pkgs.android-udev-rules ];
  };

  sops.age.keyFile = "/home/camille/.config/sops/age/keys.txt";

  # virtualisation = {
  #   waydroid.enable = true;
  #   lxd.enable = true;
  #   virtualbox.host.enable = true;
  # };
  # users.extraGroups.vboxusers.members = [ "camille" ];

  system.stateVersion = "23.05";
}
