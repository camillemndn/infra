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
  environment = {
    # Included by the greeter's own niri config, which has no input section: the touchpad as in the session.
    etc."greetd/niri_overrides.kdl".text = ''
      input {
          touchpad {
              tap
              natural-scroll
          }
      }
    '';

    systemPackages = with pkgs; [
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
  };

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
      home = {
        packages = with pkgs; [
          brightnessctl
          # Spawned by custom.kdl.
          xwayland-satellite
        ];

        # KDE apps outside Plasma: the KDE platform theme, and the menu Plasma names that "Open with" is built from.
        sessionVariables = {
          QT_QPA_PLATFORMTHEME = "kde";
          XDG_MENU_PREFIX = "plasma-";
        };
      };

      # Its qtct platform theme would take QT_QPA_PLATFORMTHEME from the KDE one above.
      stylix.targets.qt.enable = false;
      # Tailscale's own tray, run with the graphical session.
      services.tailscale-systray.enable = true;

      xdg.configFile = {
        # The config.kdl that `dms setup` writes, followed by custom.kdl; the dms/*.kdl it includes stay DankMaterialShell's to write, and are optional until DMS first writes them.
        # The backdrop shows through DMS's transparent workspace background until the wallpaper is drawn.
        "niri/config.kdl".source = pkgs.runCommand "niri-config.kdl" { } ''
          sed 's|^include "dms/|include optional=true "dms/|' \
            ${cfg.package.src}/core/internal/config/embedded/niri.kdl > $out
          printf '\noverview {\n    backdrop-color "#%s"\n}\n' ${
            if config.stylix.enable then config.lib.stylix.colors.base00 else "000000"
          } >> $out
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
