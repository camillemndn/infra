{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    idevicerestore
    ifuse
    libimobiledevice
    libirecovery
  ];

  home-manager.users.camille =
    { pkgs, ... }:

    {
      home = {
        packages = with pkgs; [
          # Social
          mattermost-desktop
          signal-desktop

          # Desk
          pdftocgen
          xournalpp
          zotero

          # Sync
          bitwarden-cli

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
        kitty.enable = true;
        vscodium.enable = true;
      };

      stylix.targets.fish.enable = false;
    };

  programs = {
    dms-shell.enable = true;
    localsend.enable = true;
    nixvim.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    logind.settings.Login.KillUserProcesses = true;
    power-profiles-daemon.enable = false;
    usbmuxd.enable = true;
  };

  stylix.enable = true;
  system.stateVersion = "23.11";
}
