{
  home-manager.users.camille =
    { pkgs, ... }:

    {
      home = {
        packages = with pkgs; [
          # Games
          prismlauncher
          xwayland-satellite

          # Social
          mattermost-desktop
          signal-desktop

          # Desk
          libreoffice-qt-fresh
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
          nextcloud-client
          qbittorrent
          tailscale-systray

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

        emacs.enable = true;
        kitty.enable = true;
        thunderbird.enable = true;
        vscodium.enable = true;
        waybar.bluetooth.enable = true;
      };

      services.nextcloud-client.enable = true;

      stylix = {
        targets = {
          fish.enable = false;
          qt.enable = false;
        };
      };

      wayland.windowManager.sway.enable = true;
    };
}
