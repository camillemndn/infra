{
  home-manager.users.camille =
    { pkgs, ... }:

    {
      home = {
        packages = with pkgs; [
          # Social
          mattermost-desktop
          signal-desktop

          # Desk
          libreoffice-qt-fresh
          pdftocgen
          xournalpp
          zotero

          # Sync
          bitwarden-cli
          tailscale-systray

          # Graphics
          inkscape-with-extensions

          # Music & Video
          feishin
          mpv
          spotify
        ];
        stateVersion = "23.11";
      };

      programs = {
        emacs.enable = true;
        kitty.enable = true;
        thunderbird.enable = true;
      };

      stylix.targets.fish.enable = false;
      wayland.windowManager.sway.enable = true;
    };
}
