{ pkgs, ... }:

{
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    tmp.cleanOnBoot = true;
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

  fonts.packages = with pkgs; [
    caladea
    carlito
    ibm-plex
    jetbrains-mono
    liberation_ttf
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    roboto
    roboto-slab
    source-code-pro
    source-sans
    source-serif
  ];

  hardware.sane = {
    enable = true;
    dsseries.enable = true;
  };

  home-manager.users.camille =
    { pkgs, ... }:

    {
      home = {
        packages = with pkgs; [
          # Games
          prismlauncher

          # Social
          mattermost-desktop
          signal-desktop

          # Desk
          tocpdf
          xournalpp
          zotero
          unstable.gramps

          # Tools
          ocrmypdf
          organize-tool
          pdfarranger

          # Sync
          bitwarden-cli
          joplin-desktop
          qbittorrent

          # Graphics
          darktable
          gimp-with-plugins
          inkscape-with-extensions

          # Music & Video
          feishin
          ffmpeg
          harmony-assistant
          jellyfin-media-player
          kdePackages.kdenlive
          lilypond-with-fonts
          mmt
          mpv
          musescore
          spotify

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

        stateVersion = "23.05";
      };

      programs = {
        chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;
        };

        kitty.enable = true;
        vscodium.enable = true;
      };

      stylix = {
        targets = {
          fish.enable = false;
          qt.enable = false;
        };
      };
    };

  programs = {
    dms-shell.enable = true;
    localsend.enable = true;
    nixvim.enable = true;
  };

  # Real-time audio for the studio software.
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];

  services = {
    desktopManager.plasma6.enable = true;

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

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    openssh.enable = false;
    pipewire.jack.enable = true;

    printing.drivers = with pkgs; [
      cups-brother-hll2340dw
      samsung-unified-linux-driver
    ];

    tzupdate.enable = true;
    usbmuxd.enable = true;
  };

  stylix.enable = true;
  system.stateVersion = "23.05";
}
