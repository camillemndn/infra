{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dms-shell;
in

lib.mkIf cfg.enable {
  environment.systemPackages = with pkgs; [
    bitwarden-cli
    feishin
    mattermost-desktop
    nemo
    signal-desktop
    spotify
    xournalpp
    yazi
    zotero
  ];

  fonts.packages = with pkgs; [
    caladea
    carlito
    ibm-plex
    inter
    jetbrains-mono
    liberation_ttf
    material-symbols
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    roboto
    roboto-slab
    source-code-pro
    source-sans
    source-serif
  ];

  home-manager.sharedModules = [
    {
      home.packages = with pkgs; [
        brightnessctl
        # Spawned by custom.kdl.
        xwayland-satellite
      ];

      # Tailscale's own tray, run with the graphical session.
      services.tailscale-systray.enable = true;

      xdg.configFile = {
        # The config.kdl that `dms setup` writes, followed by custom.kdl; the dms/*.kdl it includes stay DankMaterialShell's to write, and are optional until DMS first writes them.
        "niri/config.kdl".source = pkgs.runCommand "niri-config.kdl" { } ''
          sed 's|^include "dms/|include optional=true "dms/|' \
            ${cfg.package.src}/core/internal/config/embedded/niri.kdl > $out
          printf '\ninclude "custom.kdl"\n' >> $out
        '';

        "niri/custom.kdl".source = ./custom.kdl;
      };
    }
  ];

  programs = {
    dms-shell.systemd.target = "niri.service";
    # Indexes files for the launcher's file search.
    dsearch.enable = true;
    localsend.enable = true;
    niri.enable = lib.mkDefault true;
  };

  services.displayManager.dms-greeter = {
    enable = lib.mkDefault true;
    compositor.name = lib.mkDefault "niri";
  };
}
