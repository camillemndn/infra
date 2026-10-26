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
  # Included by the greeter's own niri config, which has no input section: the touchpad as in the session.
  environment.etc."greetd/niri_overrides.kdl".text = ''
    input {
        touchpad {
            tap
            natural-scroll
        }
    }
  '';

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
          xwayland-satellite # Started by niri when an X11 client connects.
          bitwarden-cli
          feishin
          kdePackages.dolphin
          mattermost-desktop
          signal-desktop
          spotify
          xournalpp
          zotero
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
        "niri/config.kdl".source = pkgs.runCommand "niri-config.kdl" { } ''
          sed 's|^include "dms/|include optional=true "dms/|' \
            ${cfg.package.src}/core/internal/config/embedded/niri.kdl > $out
          printf '\ninclude "custom.kdl"\n' >> $out
        '';

        "niri/custom.kdl".source = pkgs.replaceVars ./custom.kdl {
          base00 = if config.stylix.enable then config.lib.stylix.colors.base00 else "000000";
        };
      };
    }
  ];

  programs = {
    dms-shell = {
      # 2.x, for plugins whose manifest lists several `components`; packaged as dux-shell there.
      package = pkgs.unstable.dux-shell;
      quickshell.package = pkgs.unstable.quickshell;
      systemd.target = "niri.service";

      # Bar widget driving gpu-screen-recorder, with system and microphone audio.
      plugins.screenRecorder.src = pkgs.fetchFromGitHub {
        owner = "arqueon";
        repo = "dms-screen-recorder";
        rev = "1e25de9d16e63871d53b21127d31af026fa60cd6";
        hash = "sha256-Q0NgtSpP74Gpx5LJWslqcBuVZ2jrjpY+2Ae1sBId6Fs=";
      };
    };

    # Indexes files for the launcher's file search.
    dsearch.enable = true;
    # setcap wrapper for gsr-kms-server: recording without a prompt.
    gpu-screen-recorder.enable = true;
    localsend.enable = true;
    niri.enable = lib.mkDefault true;
  };

  services.displayManager.dms-greeter = {
    enable = lib.mkDefault true;
    compositor.name = lib.mkDefault "niri";
    # This module runs the greeter from share/quickshell/dms, which dux-shell does not install.
    package = pkgs.dms-shell;
    quickshell.package = pkgs.quickshell;
  };
}
