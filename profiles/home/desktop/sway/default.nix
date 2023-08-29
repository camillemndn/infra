{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.sway;
in
with lib;

{
  options.profiles.sway = {
    enable = mkEnableOption "activate sway WM";
  };

  config = mkIf cfg.enable {
    profiles.waybar.enable = true;
    profiles.launcher.enable = true;
    profiles.kitty.enable = true;

    home.packages = with pkgs; [ swww brightnessctl pamixer asusctl ];

    gtk = {
      enable = true;

      theme = {
        name = "Catppuccin-Mocha-Standard-Mauve-Dark";
        package = pkgs.catppuccin-gtk;
      };

      iconTheme = {
        name = "Yaru-dark";
        package = pkgs.yaru-theme;
      };

      #font = {
      #  name = "Inter";
      #  size = 13;
      #};

      gtk3.extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-decoration-layout = "menu:";
      };

      gtk2.extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita-dark";
      };
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
    };

    home.sessionVariables = {
      # Theming Related Variables
      XCURSOR_SIZE = "96";
    };

    wayland.windowManager.sway = let cfg = config.wayland.windowManager.sway; in {
      enable = true;
      config = {
        bars = [ ];
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

          "XF86AudioMute" = "exec pamixer -t";
          # "XF86AudioLowerVolume" = "";
          # "XF86AudioRaiseVolume" = "";
          "XF86KbdBrightnessDown" = "exec asusctl -p";
          "XF86KbdBrightnessUp" = "exec asusctl -n";
          "XF86MonBrightnessDown" = "exec brightnessctl s '1%-'";
          "XF86MonBrightnessUp" = "exec brightnessctl s '+1%'";
        };
        menu = "fuzzel";
        # menu = "rofi -modi drun -show";
        modifier = "Mod4";
        #output."*".scale = "2";
        startup = [
          { command = "swww init; swww img ~/Images/.cats.jpg"; always = true; }
          { command = "waybar"; always = true; }
        ];
        terminal = "kitty";
        window.titlebar = false;
      };
    };
  };
}

