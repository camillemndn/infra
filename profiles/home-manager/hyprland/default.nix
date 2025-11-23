{
  config,
  lib,
  pkgs,
  ...
}:

let
  mod = "SUPER";
  wl-ocr = pkgs.writeShellScriptBin "wl-ocr" ''
    ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" -t ppm - | ${lib.getExe pkgs.tesseract5} - - | ${pkgs.wl-clipboard}/bin/wl-copy
    ${lib.getExe pkgs.libnotify} "$(${pkgs.wl-clipboard}/bin/wl-paste)"
  '';
in

lib.mkIf config.wayland.windowManager.hyprland.enable {
  home.packages = with pkgs; [
    brightnessctl
    grim
    slurp
    wl-ocr
  ];

  programs = {
    fuzzel.enable = true;
    kitty.enable = true;
    swaylock.enable = true;
    waybar.enable = true;
    wlogout.enable = true;
  };

  wayland.windowManager.hyprland.settings = {
    # Autostart
    exec-once = [
      "tailscale-systray"
      "waybar"
    ];

    # Input configuration
    input = {
      kb_layout = "fr";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = true;
        tap-to-click = true;
      };
    };

    # Look & feel
    general = {
      gaps_in = 6;
      gaps_out = 12;
      border_size = 2;
      layout = "dwindle";
    };

    decoration = {
      blur = {
        enabled = true;
        size = 8;
        passes = 2;
      };
      inactive_opacity = 0.8;
      rounding = 8;
    };

    # Window management and launching
    bind = [
      # Launchers
      "${mod}, RETURN, exec, kitty"
      "${mod}, D, exec, fuzzel"

      # Browser, file manager, code editor
      "${mod} SHIFT, B, exec, firefox"
      "${mod} SHIFT, F, exec, nautilus"

      # Window management
      "${mod}, Q, killactive"
      "${mod}, F, fullscreen"
      "${mod}, Space, togglefloating"
      "${mod}, P, pseudo"
      "${mod}, J, togglesplit"

      # System
      "${mod}, M, exit"

      # Screenshot
      "${mod} SHIFT, S, exec, sh -c 'slurp | grim -g - \"$(xdg-user-dir PICTURES)/Captures d’écran/$(date +%Y%m%d_%H%M%S.png)\"'"

      # Lock screen
      "${mod}, Escape, exec, swaylock"

      # Audio
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"

      # Keyboard brightness (asusctl)
      ", XF86KbdBrightnessDown, exec, asusctl -p"
      ", XF86KbdBrightnessUp, exec, asusctl -n"

      # Monitor brightness (brightnessctl)
      ", XF86MonBrightnessDown, exec, brightnessctl s '1%-'"
      ", XF86MonBrightnessUp, exec, brightnessctl s '+1%'"
    ]
    ++ (builtins.concatLists (
      builtins.genList (
        i:
        let
          ws = toString (i + 1);
          keycode = "code:1${toString i}";
        in
        [
          "${mod}, ${keycode}, workspace, ${ws}"
          "${mod} SHIFT, ${keycode}, movetoworkspace, ${ws}"
        ]
      ) 10
    ));

    # Mouse interactions
    bindm = [
      "${mod}, mouse:272, movewindow"
      "${mod}, mouse:273, resizewindow"
    ];

    # Optional gestures (if using touchpad)
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
    };

    # Decorations (optional eye candy)
    animations = {
      enabled = true;
      animation = [
        "windows, 1, 5, default, slide"
        "workspaces, 1, 5, default, slidevert"
      ];
    };

    # Miscellaneous preferences
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };

    monitor = [ "desc:Sharp Corporation LQ134R1JW51, preferred, auto, 2.5" ];
  };
}
