{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.sway;
  makePluginPath = format:
    (lib.makeSearchPath format [
      "$HOME/.nix-profile/lib"
      "/run/current-system/sw/lib"
      "/etc/profiles/per-user/$USER/lib"
    ])
    + ":$HOME/.${format}";
  envVars = lib.replaceStrings [ "\n" ] [ " " ] (lib.toShellVars {
    NIXOS_OZONE_WL = 1;
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "gnome";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=3.0";
    DSSI_PATH = makePluginPath "dssi";
    LADSPA_PATH = makePluginPath "ladspa";
    LV2_PATH = makePluginPath "lv2";
    LXVST_PATH = makePluginPath "lxvst";
    VST_PATH = makePluginPath "vst";
    VST3_PATH = makePluginPath "vst3";
  });
in
with lib;

{
  options.profiles.sway = {
    enable = mkEnableOption "Sway WM";
  };

  config = mkIf cfg.enable {
    profiles = {
      gtk-qt.enable = true;
      kitty.enable = true;
      launcher.enable = true;
      swaylock.enable = true;
      waybar.enable = true;
      wlogout.enable = true;
    };

    home.packages = with pkgs; [ swww brightnessctl asusctl wl-clipboard grim slurp swayest-workstyle ];

    wayland.windowManager.sway = let cfg = config.wayland.windowManager.sway; in {
      enable = true;
      extraConfig = ''
        bindswitch --reload --locked lid:on exec swaylock
        bar { 
          swaybar_command waybar
        }
      '';
      config = {
        bars = [ ];
        floating.criteria = [{ app_id = "signal"; }];
        gaps.inner = 8;
        gaps.smartBorders = "on";
        input."*" = { xkb_layout = "fr"; natural_scroll = "enabled"; tap = "enabled"; };
        keybindings = {
          "${cfg.config.modifier}+Return" = "exec ${cfg.config.terminal}";
          "${cfg.config.modifier}+Shift+q" = "kill";
          "${cfg.config.modifier}+d" = "exec ${cfg.config.menu}";

          "${cfg.config.modifier}+${cfg.config.left}" = "focus left";
          "${cfg.config.modifier}+${cfg.config.down}" = "focus down";
          "${cfg.config.modifier}+${cfg.config.up}" = "focus up";
          "${cfg.config.modifier}+${cfg.config.right}" = "focus right";

          "${cfg.config.modifier}+Left" = "focus left";
          "${cfg.config.modifier}+Down" = "focus down";
          "${cfg.config.modifier}+Up" = "focus up";
          "${cfg.config.modifier}+Right" = "focus right";

          "${cfg.config.modifier}+Shift+${cfg.config.left}" = "move left";
          "${cfg.config.modifier}+Shift+${cfg.config.down}" = "move down";
          "${cfg.config.modifier}+Shift+${cfg.config.up}" = "move up";
          "${cfg.config.modifier}+Shift+${cfg.config.right}" = "move right";

          "${cfg.config.modifier}+Shift+Left" = "move left";
          "${cfg.config.modifier}+Shift+Down" = "move down";
          "${cfg.config.modifier}+Shift+Up" = "move up";
          "${cfg.config.modifier}+Shift+Right" = "move right";

          "${cfg.config.modifier}+b" = "splith";
          "${cfg.config.modifier}+v" = "splitv";
          "${cfg.config.modifier}+f" = "fullscreen toggle";
          "${cfg.config.modifier}+a" = "focus parent";

          "${cfg.config.modifier}+s" = "layout stacking";
          "${cfg.config.modifier}+w" = "layout tabbed";
          "${cfg.config.modifier}+e" = "layout toggle split";

          "${cfg.config.modifier}+Shift+space" = "floating toggle";
          "${cfg.config.modifier}+space" = "focus mode_toggle";

          "${cfg.config.modifier}+Shift+t" = "move scratchpad";
          "${cfg.config.modifier}+t" = "scratchpad show";

          "${cfg.config.modifier}+Shift+c" = "reload";
          "${cfg.config.modifier}+Shift+e" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

          "${cfg.config.modifier}+r" = "mode resize";

          "${cfg.config.modifier}+ampersand" = "workspace number 1";
          "${cfg.config.modifier}+eacute" = "workspace number 2";
          "${cfg.config.modifier}+quotedbl" = "workspace number 3";
          "${cfg.config.modifier}+apostrophe" = "workspace number 4";
          "${cfg.config.modifier}+parenleft" = "workspace number 5";
          "${cfg.config.modifier}+minus" = "workspace number 6";
          "${cfg.config.modifier}+egrave" = "workspace number 7";
          "${cfg.config.modifier}+underscore" = "workspace number 8";
          "${cfg.config.modifier}+ccedilla" = "workspace number 9";

          "${cfg.config.modifier}+1" = "move container to workspace number 1";
          "${cfg.config.modifier}+2" = "move container to workspace number 2";
          "${cfg.config.modifier}+3" = "move container to workspace number 3";
          "${cfg.config.modifier}+4" = "move container to workspace number 4";
          "${cfg.config.modifier}+5" = "move container to workspace number 5";
          "${cfg.config.modifier}+6" = "move container to workspace number 6";
          "${cfg.config.modifier}+7" = "move container to workspace number 7";
          "${cfg.config.modifier}+8" = "move container to workspace number 8";
          "${cfg.config.modifier}+9" = "move container to workspace number 9";

          "${cfg.config.modifier}+Shift+s" = "exec slurp | grim -g - \"$(xdg-user-dir PICTURES)/Captures d’écran/$(date +%Y%m%d_%H%M%S.png)\"";
          "${cfg.config.modifier}+Escape" = "exec swaylock";

          "XF86AudioMute" = "exec amixer set Master toggle";
          "XF86AudioLowerVolume" = "exec amixer set Master 1%-";
          "XF86AudioRaiseVolume" = "exec amixer set Master 1%+";
          "XF86KbdBrightnessDown" = "exec asusctl -p";
          "XF86KbdBrightnessUp" = "exec asusctl -n";
          "XF86MonBrightnessDown" = "exec brightnessctl s '1%-'";
          "XF86MonBrightnessUp" = "exec brightnessctl s '+1%'";
        };
        menu = "${envVars} fuzzel";
        modifier = "Mod4";
        output."HDMI-A-1" = mkIf config.profiles.gtk-qt.hidpi.enable {
          scale = "0.8";
          position = "-2400 0";
        };
        input."1267:11394:ELAN9008:00_04F3:2C82_Stylus" = {
          drag = "enable";
          drag_lock = "enable";
          map_to_output = "eDP-1";
        };
        startup = [
          { command = "${pkgs.writeShellScript "sway-autorotate" ./autorotate.sh}"; }
          { command = "swww init; swww img ~/Images/.cats.jpg"; always = true; }
          { command = "tailscale-systray"; }
          { command = "sworkstyle &> /tmp/sworkstyle.log"; always = true; }
        ];
        terminal = "kitty";
        window.titlebar = false;
      };
    };
  };
}


