{
  config,
  lib,
  pkgs,
  ...
}:

let
  makePluginPath =
    format:
    (lib.makeSearchPath format [
      "$HOME/.nix-profile/lib"
      "/run/current-system/sw/lib"
      "/etc/profiles/per-user/$USER/lib"
    ])
    + ":$HOME/.${format}";
  envVars = lib.replaceStrings [ "\n" ] [ " " ] (
    lib.toShellVars {
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
    }
  );
in

lib.mkIf config.wayland.windowManager.sway.enable {
  gtk.enable = true;

  programs = {
    fuzzel.enable = true;
    kitty.enable = true;
    swaylock.enable = true;
    waybar.enable = true;
    wlogout.enable = true;
  };

  home.packages = with pkgs; [
    brightnessctl
    grim
    slurp
    swayest-workstyle
    swww
    wl-clipboard
  ];

  wayland.windowManager.sway =
    let
      cfg = config.wayland.windowManager.sway.config;
    in
    {
      extraConfig = ''
        bindswitch --reload --locked lid:on exec swaylock
        bar { 
          swaybar_command waybar
        }
      '';
      config = {
        bars = [ ];
        floating.criteria = [ { app_id = "signal"; } ];
        gaps.inner = 8;
        gaps.smartBorders = "on";
        input."*" = {
          xkb_layout = "fr";
          natural_scroll = "enabled";
          tap = "enabled";
        };
        keybindings = {
          "${cfg.modifier}+Return" = "exec ${cfg.terminal}";
          "${cfg.modifier}+Shift+q" = "kill";
          "${cfg.modifier}+d" = "exec ${cfg.menu}";

          "${cfg.modifier}+${cfg.left}" = "focus left";
          "${cfg.modifier}+${cfg.down}" = "focus down";
          "${cfg.modifier}+${cfg.up}" = "focus up";
          "${cfg.modifier}+${cfg.right}" = "focus right";

          "${cfg.modifier}+Left" = "focus left";
          "${cfg.modifier}+Down" = "focus down";
          "${cfg.modifier}+Up" = "focus up";
          "${cfg.modifier}+Right" = "focus right";

          "${cfg.modifier}+Shift+${cfg.left}" = "move left";
          "${cfg.modifier}+Shift+${cfg.down}" = "move down";
          "${cfg.modifier}+Shift+${cfg.up}" = "move up";
          "${cfg.modifier}+Shift+${cfg.right}" = "move right";

          "${cfg.modifier}+Shift+Left" = "move left";
          "${cfg.modifier}+Shift+Down" = "move down";
          "${cfg.modifier}+Shift+Up" = "move up";
          "${cfg.modifier}+Shift+Right" = "move right";

          "${cfg.modifier}+b" = "splith";
          "${cfg.modifier}+v" = "splitv";
          "${cfg.modifier}+f" = "fullscreen toggle";
          "${cfg.modifier}+a" = "focus parent";

          "${cfg.modifier}+s" = "layout stacking";
          "${cfg.modifier}+w" = "layout tabbed";
          "${cfg.modifier}+e" = "layout toggle split";

          "${cfg.modifier}+Shift+space" = "floating toggle";
          "${cfg.modifier}+space" = "focus mode_toggle";

          "${cfg.modifier}+Shift+t" = "move scratchpad";
          "${cfg.modifier}+t" = "scratchpad show";

          "${cfg.modifier}+Shift+c" = "reload";
          "${cfg.modifier}+Shift+e" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

          "${cfg.modifier}+r" = "mode resize";

          "${cfg.modifier}+ampersand" = "workspace number 1";
          "${cfg.modifier}+eacute" = "workspace number 2";
          "${cfg.modifier}+quotedbl" = "workspace number 3";
          "${cfg.modifier}+apostrophe" = "workspace number 4";
          "${cfg.modifier}+parenleft" = "workspace number 5";
          "${cfg.modifier}+minus" = "workspace number 6";
          "${cfg.modifier}+egrave" = "workspace number 7";
          "${cfg.modifier}+underscore" = "workspace number 8";
          "${cfg.modifier}+ccedilla" = "workspace number 9";

          "${cfg.modifier}+1" = "move container to workspace number 1";
          "${cfg.modifier}+2" = "move container to workspace number 2";
          "${cfg.modifier}+3" = "move container to workspace number 3";
          "${cfg.modifier}+4" = "move container to workspace number 4";
          "${cfg.modifier}+5" = "move container to workspace number 5";
          "${cfg.modifier}+6" = "move container to workspace number 6";
          "${cfg.modifier}+7" = "move container to workspace number 7";
          "${cfg.modifier}+8" = "move container to workspace number 8";
          "${cfg.modifier}+9" = "move container to workspace number 9";

          "${cfg.modifier}+Shift+s" =
            "exec slurp | grim -g - \"$(xdg-user-dir PICTURES)/Captures d’écran/$(date +%Y%m%d_%H%M%S.png)\"";
          "${cfg.modifier}+Escape" = "exec swaylock";

          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
          "XF86KbdBrightnessDown" = "exec asusctl -p";
          "XF86KbdBrightnessUp" = "exec asusctl -n";
          "XF86MonBrightnessDown" = "exec brightnessctl s '1%-'";
          "XF86MonBrightnessUp" = "exec brightnessctl s '+1%'";
        };
        menu = "${envVars} fuzzel";
        modifier = "Mod4";
        output."Hewlett Packard HP V194 3CQ9432LGC" = lib.mkIf config.gtk.hidpi.enable { scale = "0.75"; };
        input."1267:11394:ELAN9008:00_04F3:2C82_Stylus" = {
          drag = "enable";
          drag_lock = "enable";
          map_to_output = "eDP-1";
        };
        startup = [
          { command = "${pkgs.writeShellScript "sway-autorotate" ./autorotate.sh}"; }
          {
            command = "swww img ~/Images/.wallpaper.jpg";
            always = true;
          }
          { command = "tailscale-systray"; }
          {
            command = "sworkstyle &> /tmp/sworkstyle.log";
            always = true;
          }
        ];
        terminal = "kitty";
        window.titlebar = false;
      };
    };
}
