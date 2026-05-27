{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.niri;
in

{
  options.programs.niri.enable = lib.mkEnableOption "niri window manager";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      brightnessctl
      grim
      playerctl
      slurp
      swaybg
      swayest-workstyle
      wl-clipboard
      xdg-utils
    ];

    programs = {
      fuzzel.enable = true;
      kitty.enable = true;
      swaylock.enable = true;
      waybar.enable = true;
      wlogout.enable = true;
    };

    programs.niri.settings = {
      input = {
        keyboard = {
          xkb.layout = "fr";
          numlock = true;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
          dwt = true;
        };
        mouse.natural-scroll = true;
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "on-overflow";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = {
          proportion = 0.5;
        };
        focus-ring = {
          width = 3;
          active.color = "#cba6f7";
          inactive.color = "#313244";
        };
        border.enable = false;
        shadow = {
          enable = true;
          softness = 30;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#0007";
        };
        struts = {
          top = 0;
          bottom = 0;
        };
      };

      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      spawn-at-startup = [
        {
          argv = [
            "${pkgs.swaybg}/bin/swaybg"
            "-i"
            "${config.stylix.image}"
            "-m"
            "fill"
          ];
        }
        { argv = [ "waybar" ]; }
        { argv = [ "${pkgs.tailscale-systray}/bin/tailscale-systray" ]; }
      ];

      hotkey-overlay.skip-at-startup = true;

      window-rules = [
        {
          matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
          default-column-width = { };
        }
        {
          matches = [
            {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
        }
        {
          geometry-corner-radius = {
            top-left = 8.0;
            top-right = 8.0;
            bottom-left = 8.0;
            bottom-right = 8.0;
          };
          clip-to-geometry = true;
        }
      ];

      binds = {
        "Mod+Return".action.spawn = "${pkgs.kitty}/bin/kitty";
        "Mod+D".action.spawn = "${pkgs.fuzzel}/bin/fuzzel";
        "Mod+Q".action.close-window = [ ];

        "Mod+Escape".action.spawn = "${pkgs.swaylock-effects}/bin/swaylock";
        "Mod+Shift+E".action.quit = [ ];
        "Ctrl+Alt+Delete".action.quit = [ ];

        # Navigation
        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+H".action.focus-column-left = [ ];
        "Mod+J".action.focus-window-down = [ ];
        "Mod+K".action.focus-window-up = [ ];
        "Mod+L".action.focus-column-right = [ ];

        # Move windows
        "Mod+Ctrl+Left".action.move-column-left = [ ];
        "Mod+Ctrl+Down".action.move-window-down = [ ];
        "Mod+Ctrl+Up".action.move-window-up = [ ];
        "Mod+Ctrl+Right".action.move-column-right = [ ];
        "Mod+Ctrl+H".action.move-column-left = [ ];
        "Mod+Ctrl+J".action.move-window-down = [ ];
        "Mod+Ctrl+K".action.move-window-up = [ ];
        "Mod+Ctrl+L".action.move-column-right = [ ];

        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];
        "Mod+Ctrl+Home".action.move-column-to-first = [ ];
        "Mod+Ctrl+End".action.move-column-to-last = [ ];

        # Monitor focus
        "Mod+Shift+Left".action.focus-monitor-left = [ ];
        "Mod+Shift+Down".action.focus-monitor-down = [ ];
        "Mod+Shift+Up".action.focus-monitor-up = [ ];
        "Mod+Shift+Right".action.focus-monitor-right = [ ];
        "Mod+Shift+H".action.focus-monitor-left = [ ];
        "Mod+Shift+J".action.focus-monitor-down = [ ];
        "Mod+Shift+K".action.focus-monitor-up = [ ];
        "Mod+Shift+L".action.focus-monitor-right = [ ];

        # Move to monitor
        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

        # Workspaces
        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Page_Up".action.focus-workspace-up = [ ];
        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
        "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
        "Mod+Shift+Page_Up".action.move-workspace-up = [ ];

        # Workspaces by number — AZERTY (fr) unshifted top row
        "Mod+ampersand".action.focus-workspace = 1;
        "Mod+eacute".action.focus-workspace = 2;
        "Mod+quotedbl".action.focus-workspace = 3;
        "Mod+apostrophe".action.focus-workspace = 4;
        "Mod+parenleft".action.focus-workspace = 5;
        "Mod+minus".action.focus-workspace = 6;
        "Mod+egrave".action.focus-workspace = 7;
        "Mod+underscore".action.focus-workspace = 8;
        "Mod+ccedilla".action.focus-workspace = 9;
        "Mod+Ctrl+ampersand".action.move-column-to-workspace = 1;
        "Mod+Ctrl+eacute".action.move-column-to-workspace = 2;
        "Mod+Ctrl+quotedbl".action.move-column-to-workspace = 3;
        "Mod+Ctrl+apostrophe".action.move-column-to-workspace = 4;
        "Mod+Ctrl+parenleft".action.move-column-to-workspace = 5;
        "Mod+Ctrl+minus".action.move-column-to-workspace = 6;
        "Mod+Ctrl+egrave".action.move-column-to-workspace = 7;
        "Mod+Ctrl+underscore".action.move-column-to-workspace = 8;
        "Mod+Ctrl+ccedilla".action.move-column-to-workspace = 9;

        # Scroll workspaces
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-workspace-down = [ ];
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-workspace-up = [ ];
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-down = [ ];
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-up = [ ];
        };
        "Mod+WheelScrollRight".action.focus-column-right = [ ];
        "Mod+WheelScrollLeft".action.focus-column-left = [ ];
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

        # Column management
        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];

        # Layout
        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Ctrl+R".action.reset-window-height = [ ];
        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];
        "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
        "Mod+C".action.center-column = [ ];
        "Mod+Ctrl+C".action.center-visible-columns = [ ];
        "Mod+V".action.toggle-window-floating = [ ];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];
        "Mod+W".action.toggle-column-tabbed-display = [ ];
        "Mod+O".action.toggle-overview = [ ];

        # Resize
        "Mod+Alt+Minus".action.set-column-width = "-10%";
        "Mod+Alt+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # Screenshots
        "Mod+Shift+S".action.screenshot = [ ];
        "Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];

        # Media keys
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+ -l 1.0";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn = [
            "playerctl"
            "play-pause"
          ];
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action.spawn = [
            "playerctl"
            "stop"
          ];
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn = [
            "playerctl"
            "previous"
          ];
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn = [
            "playerctl"
            "next"
          ];
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [
            "brightnessctl"
            "set"
            "+1%"
          ];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [
            "brightnessctl"
            "set"
            "1%-"
          ];
        };

        # Misc
        "Mod+Shift+P".action.power-off-monitors = [ ];
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
        "Mod+Shift+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = [ ];
        };
      };
    };
  };
}
