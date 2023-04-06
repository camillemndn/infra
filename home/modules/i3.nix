{ pkgs, lib, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = rec {
      modifier = "Mod4";
      bars = [ ];

      window.border = 0;

      gaps = {
        inner = 15;
        outer = 5;
      };

      keybindings = lib.mkOptionDefault {
        "XF86AudioMute" = "exec --no-startup-id amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec --no-startup-id amixer set Master 2%-";
        "XF86AudioRaiseVolume" = "exec --no-startup-id amixer set Master 2%+";
        "XF86AudioPlay" = "exec --no-startup-id play";
        "XF86AudioPause" = "exec --no-startup-id playerctl pause";
        "XF86AudioNext" = "exec --no-startup-id next";
        "XF86AudioPrev" = "exec --no-startup-id previous";
        "XF86MonBrightnessDown" = "exec --no-startup-id /home/camille/.config/nixpkgs/modules/bright Down";
        "XF86MonBrightnessUp" = "exec --no-startup-id /home/camille/.config/nixpkgs/modules/bright Up";
        "XF86KbdBrightnessUp" = "exec --no-startup-id ${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set +1";
        "XF86KbdBrightnessDown" = "exec --no-startup-id ${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set 1-";
        "${modifier}+Return" = "exec --no-startup-id ${pkgs.alacritty}/bin/alacritty -o font.size=8"; # HiDPI
        "${modifier}+d" = "exec $HOME/.config/rofi/launchers/misc/launcher.sh";
        "${modifier}+b" = "exec ${pkgs.firefox}/bin/firefox";
        "${modifier}+Shift+b" = "exec ${pkgs.gnome.nautilus}/bin/nautilus";
        "${modifier}+Shift+x" = "exec systemctl suspend";
      };

      startup = [
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        {
          # command = "systemctl --user restart polybar.service";
          command = "/home/camille/.config/polybar/cuts/launch.sh";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-fill ~/.background-image";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.picom}/bin/picom -b";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
