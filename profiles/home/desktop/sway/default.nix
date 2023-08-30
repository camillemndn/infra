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

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        ignore-empty-password = true;
        font = "FiraCode Nerd Font Mono";
        clock = true;
        timestr = "%R";
        datestr = "%a %e %B";
        screenshots = true;
        fade-in = "0.2";
        effect-blur = "20x4";
        #effect-greyscale = true;
        effect-scale = "0.3";
        indicator = true;
        indicator-radius = "200";
        indicator-thickness = "20";
        indicator-caps-lock = true;
        #key-hl-color = "880033";
        #separator-color = "00000000";
        #inside-color = "00000099";
        #inside-clear-color = "ffd20400";
        #inside-caps-lock-color = "009ddc00";
        #inside-ver-color = "d9d8d800";
        #inside-wrong-color = "ee2e2400";
        #ring-color = "231f20D9";
        #ring-clear-color = "231f20D9";
        #ring-caps-lock-color = "231f20D9";
        #ring-ver-color = "231f20D9";
        #ring-wrong-color = "231f20D9";
        #line-color = "00000000";
        #line-clear-color = "ffd204FF";
        #line-caps-lock-color = "009ddcFF";
        #line-ver-color = "d9d8d8FF";
        #line-wrong-color = "ee2e24FF";
        #text-clear-color = "ffd20400";
        #text-ver-color = "d9d8d800";
        #text-wrong-color = "ee2e2400";
        #bs-hl-color = "ee2e24FF";
        #caps-lock-key-hl-color = "ffd204FF";
        #caps-lock-bs-hl-color = "ee2e24FF";
        #disable-caps-lock-text = true;
        #text-caps-lock-color = "009ddc";

        #image = "~/Images/.cats.jpg";
        color = "282a36";
        inside-color = "1F202A";
        line-color = "1F202A";
        ring-color = "bd93f9";
        text-color = "f8f8f2";
        layout-bg-color = "1F202A";
        layout-text-color = "f8f8f2";
        inside-clear-color = "6272a4";
        line-clear-color = "1F202A";
        ring-clear-color = "6272a4";
        text-clear-color = "1F202A";
        inside-ver-color = "bd93f9";
        line-ver-color = "1F202A";
        ring-ver-color = "bd93f9";
        text-ver-color = "1F202A";
        inside-wrong-color = "ff5555";
        line-wrong-color = "1F202A";
        ring-wrong-color = "ff5555";
        text-wrong-color = "1F202A";
        bs-hl-color = "ff5555";
        key-hl-color = "50fa7b";
        text-caps-lock-color = "f8f8f2";
      };
    };

    programs.wlogout = {
      enable = true;
      style = ''
        @import url("${pkgs.wlogout}/etc/wlogout/style.css");
        window {
            font-family: "FiraCode Nerd Font Mono";
            font-weight: bold;
            font-size: 14pt;
            color: #cdd6f4;
            background-color: rgba(30, 30, 46, 0.85);
        }
        button {
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
            border: none;
            background-color: rgba(30, 30, 46, 0);
            margin: 5px;
            transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
        }
        button:hover {
            background-color: rgba(49, 50, 68, 0.1);
        }
        button:focus {
            background-color: #cba6f7;
            color: #1e1e2e;
        }
        #lock:focus {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/lock.svg"));
        }
        
        #logout:focus {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/logout.svg"));
        }
        
        #suspend:focus {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/suspend.svg"));
        }
        
        #hibernate:focus {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/hibernate.svg"));
        }
        
        #shutdown:focus {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/shutdown.svg"));
        }
        
        #reboot:focus {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/assets/reboot.svg"));
        }
      '';
    };

    home.packages = with pkgs; [ swww brightnessctl asusctl wl-clipboard grim slurp ];

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
      extraConfig = ''
        bindswitch --reload --locked lid:on exec swaylock
      '';
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

          "${cfg.config.modifier}+Shift+s" = "exec slurp | grim -g - - | wl-copy";
          "${cfg.config.modifier}+Escape" = "exec swaylock";

          "XF86AudioMute" = "exec amixer set Master toggle";
          "XF86AudioLowerVolume" = "exec amixer set Master 1%-";
          "XF86AudioRaiseVolume" = "exec amixer set Master 1%+";
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


