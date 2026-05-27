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

    xdg.configFile."niri/config.kdl".text = ''
      input {
          keyboard {
              xkb {
                  layout "fr"
              }
              numlock
          }

          touchpad {
              tap
              natural-scroll
              dwtp
          }

          mouse {
              natural-scroll
          }

          focus-follows-mouse max-scroll-amount="0%"
      }

      layout {
          gaps 8

          center-focused-column "on-overflow"

          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }

          default-column-width { proportion 0.5; }

          focus-ring {
              width 3
              active-color "#cba6f7"
              inactive-color "#313244"
          }

          border {
              off
          }

          shadow {
              on
              softness 30
              spread 5
              offset x=0 y=5
              color "#0007"
          }

          struts {
              top 0
              bottom 0
          }
      }

      prefer-no-csd

      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      spawn-at-startup "waybar"
      spawn-at-startup "${pkgs.tailscale-systray}/bin/tailscale-systray"

      hotkey-overlay {
          skip-at-startup
      }

      animations {}

      window-rule {
          match app-id=r#"^org\.wezfurlong\.wezterm$"#
          default-column-width {}
      }

      window-rule {
          match app-id=r#"firefox$"# title="^Picture-in-Picture$"
          open-floating true
      }

      window-rule {
          geometry-corner-radius 8
          clip-to-geometry true
      }

      binds {
          Mod+Return { spawn "${pkgs.kitty}/bin/kitty"; }
          Mod+D { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
          Mod+Q { close-window; }

          Mod+Escape { spawn "${pkgs.swaylock-effects}/bin/swaylock"; }
          Mod+Shift+E { quit; }
          Ctrl+Alt+Delete { quit; }

          // Navigation
          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          // Move windows
          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }

          Mod+Home      { focus-column-first; }
          Mod+End       { focus-column-last; }
          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End  { move-column-to-last; }

          // Monitor focus
          Mod+Shift+Left  { focus-monitor-left; }
          Mod+Shift+Down  { focus-monitor-down; }
          Mod+Shift+Up    { focus-monitor-up; }
          Mod+Shift+Right { focus-monitor-right; }
          Mod+Shift+H     { focus-monitor-left; }
          Mod+Shift+J     { focus-monitor-down; }
          Mod+Shift+K     { focus-monitor-up; }
          Mod+Shift+L     { focus-monitor-right; }

          // Move to monitor
          Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
          Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

          // Workspaces
          Mod+Page_Down      { focus-workspace-down; }
          Mod+Page_Up        { focus-workspace-up; }
          Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
          Mod+Shift+Page_Down { move-workspace-down; }
          Mod+Shift+Page_Up   { move-workspace-up; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+Ctrl+1 { move-column-to-workspace 1; }
          Mod+Ctrl+2 { move-column-to-workspace 2; }
          Mod+Ctrl+3 { move-column-to-workspace 3; }
          Mod+Ctrl+4 { move-column-to-workspace 4; }
          Mod+Ctrl+5 { move-column-to-workspace 5; }
          Mod+Ctrl+6 { move-column-to-workspace 6; }
          Mod+Ctrl+7 { move-column-to-workspace 7; }
          Mod+Ctrl+8 { move-column-to-workspace 8; }
          Mod+Ctrl+9 { move-column-to-workspace 9; }

          // Scroll workspaces
          Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
          Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
          Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }
          Mod+WheelScrollRight      { focus-column-right; }
          Mod+WheelScrollLeft       { focus-column-left; }
          Mod+Ctrl+WheelScrollRight { move-column-right; }
          Mod+Ctrl+WheelScrollLeft  { move-column-left; }

          // Column management
          Mod+BracketLeft  { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }
          Mod+Comma  { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }

          // Layout
          Mod+R       { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+Ctrl+R  { reset-window-height; }
          Mod+F       { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+Ctrl+F  { expand-column-to-available-width; }
          Mod+C       { center-column; }
          Mod+Ctrl+C  { center-visible-columns; }
          Mod+V       { toggle-window-floating; }
          Mod+Shift+V { switch-focus-between-floating-and-tiling; }
          Mod+W       { toggle-column-tabbed-display; }
          Mod+O       { toggle-overview; }

          // Resize
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          // Screenshots
          Mod+Shift+S { screenshot; }
          Print       { screenshot-screen; }
          Alt+Print   { screenshot-window; }

          // Media keys
          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+ -l 1.0"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-"; }
          XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
          XF86AudioPlay        allow-when-locked=true { spawn "playerctl" "play-pause"; }
          XF86AudioStop        allow-when-locked=true { spawn "playerctl" "stop"; }
          XF86AudioPrev        allow-when-locked=true { spawn "playerctl" "previous"; }
          XF86AudioNext        allow-when-locked=true { spawn "playerctl" "next"; }
          XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "+1%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "1%-"; }

          // Misc
          Mod+Shift+P { power-off-monitors; }
          Mod+Shift+Slash { show-hotkey-overlay; }
          Mod+Shift+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
      }
    '';
  };
}
