{ pkgs, ... }:

{
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    tmp.cleanOnBoot = true;
  };

  environment.systemPackages = with pkgs; [
    android-tools
    signalbackup-tools
  ];

  hardware.sane = {
    enable = true;
    dsseries.enable = true;
  };

  home-manager.users.camille = {
    programs = {
      chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
      };

      vscodium.enable = true;
    };

    home.stateVersion = "23.05";
  };

  programs = {
    dms-shell.enable = true;
    nixvim.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    openssh.enable = false;

    pipewire = {
      jack.enable = true;

      # Lists network PulseAudio sinks announced over Avahi, such as radiogaga,
      # with a fixed 500 ms latency on their tunnels.
      extraConfig.pipewire-pulse."10-zeroconf-discover"."pulse.cmd" = [
        {
          cmd = "load-module";
          args = "module-zeroconf-discover latency_msec=500";
        }
      ];
    };

    printing.drivers = with pkgs; [
      cups-brother-hll2340dw
      samsung-unified-linux-driver
    ];

    tzupdate.enable = true;
  };

  stylix.enable = true;

  users.users.camille.packages = with pkgs; [
    # Games
    prismlauncher

    # Desk
    tocpdf
    unstable.gramps

    # Tools
    ocrmypdf
    organize-tool
    pdfarranger

    # Sync
    joplin-desktop
    qbittorrent

    # Graphics
    darktable

    # Music & Video
    ffmpeg
    harmony-assistant
    jellyfin-media-player
    kdePackages.kdenlive
    lilypond-with-fonts
    mmt
    musescore

    # Studio
    ardour
    audacity
    drumgizmo
    gxplugins-lv2
    lenmus
    lmms
    lsp-plugins
    luppp
    zam-plugins
    zrythm
  ];

  system.stateVersion = "23.05";
}
