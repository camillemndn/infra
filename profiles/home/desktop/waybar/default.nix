{ config, lib, ... }:

let
  cfg = config.profiles.waybar;
  launcher = "fuzzel";
in
with lib;

{
  options.profiles.waybar = {
    enable = mkEnableOption "waybar";
    bluetooth.enable = mkEnableOption "bluetooth";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = false;
        target = "graphical-session.target";
      };
      style = ''
        * {
          font-family: "FiraCode Nerd Font Mono";
          font-size: 10pt;
          font-weight: bold;
          border-radius: 8px;
          transition-property: background-color;
          transition-duration: 0.5s;
        }
        @keyframes blink_red {
          to {
            background-color: rgb(242, 143, 173);
            color: rgb(26, 24, 38);
          }
        }
        .warning, .critical, .urgent {
          animation-name: blink_red;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        window#waybar {
          background-color: transparent;
        }
        window > box {
          margin-left: 5px;
          margin-right: 5px;
          margin-top: 5px;
          background-color: #1e1e2a;
          padding: 3px;
          padding-left:8px;
          border: 2px none #33ccff;
        }
        #workspaces {
                padding-left: 0px;
                padding-right: 4px;
              }
        #workspaces button {
                padding-top: 5px;
                padding-bottom: 5px;
                padding-left: 6px;
                padding-right: 6px;
              }
        #workspaces button.active {
                background-color: rgb(181, 232, 224);
                color: rgb(26, 24, 38);
              }
        #workspaces button.urgent {
                color: rgb(26, 24, 38);
              }
        #workspaces button:hover {
                background-color: rgb(248, 189, 150);
                color: rgb(26, 24, 38);
              }
              tooltip {
                background: rgb(48, 45, 65);
              }
              tooltip label {
                color: rgb(217, 224, 238);
              }
        #custom-launcher {
                font-size: 20px;
                padding-left: 8px;
                padding-right: 6px;
                color: #7ebae4;
              }
        #mode, #clock, #memory, #disk, #workspaces, #temperature,#cpu,#mpd, #custom-wall, #temperature, #backlight, #pulseaudio, #network, #bluetooth, #battery, #custom-powermenu, #custom-cava-internal {
                padding-left: 10px;
                padding-right: 10px;
              }
              /* #mode { */
              /* 	margin-left: 10px; */
              /* 	background-color: rgb(248, 189, 150); */
              /*     color: rgb(26, 24, 38); */
              /* } */
        #memory {
                color: rgb(181, 232, 224);
              }
        #cpu {
                color: rgb(245, 194, 231);
              }
        #clock, #disk, #battery, #bluetooth, #workspaces button {
                color: rgb(217, 224, 238);
              }
        /* #idle_inhibitor {
                 color: rgb(221, 182, 242);
               }*/
        #custom-wall {
                color: #33ccff;
           }
        #temperature {
                color: rgb(150, 205, 251);
              }
        #backlight {
                color: rgb(248, 189, 150);
              }
        #pulseaudio {
                color: rgb(245, 224, 220);
              }
        #network {
                color: #ABE9B3;
              }
        #network.disconnected {
                color: rgb(255, 255, 255);
              }
        #custom-powermenu {
                color: rgb(242, 143, 173);
                padding-right: 8px;
              }
        #tray {
                padding-right: 8px;
                padding-left: 10px;
              }
        #mpd.paused {
                color: #414868;
                font-style: italic;
              }
        #mpd.stopped {
                background: transparent;
              }
        #mpd {
                color: #c0caf5;
              }
        #custom-cava-internal {
                font-family: "Hack Nerd Font" ;
                color: #33ccff;
              }
      '';
      settings = [
        {
          "layer" = "top";
          "position" = "top";
          modules-left = [
            "custom/launcher"
            "temperature"
            "cpu"
            "memory"
            "disk"
            "sway/workspaces"
          ];
          modules-center = [ "clock" ];
          modules-right = [
            "battery"
            "backlight"
            "pulseaudio"
            (lib.optionalString cfg.bluetooth.enable "bluetooth")
            "network"
            "tray"
            "custom/powermenu"
          ];
          "backlight" = {
            "format" = "{icon} {percent}%";
            "format-icons" = [
              ""
              ""
            ];
          };
          "sway/workspaces" = {
            "disable-scroll" = true;
            "all-outputs" = true;
          };
          "bluetooth" = {
            "format" = " {status}";
            "format-connected" = " {device_alias}";
            "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
            "on-click" = "STATE=`bluetoothctl show | grep Powered | awk '{print $2}'`; if [[ $STATE == 'yes' ]]; then bluetoothctl power off; else bluetoothctl power on; fi";
            "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
            "tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          };
          "custom/launcher" = {
            "format" = " ";
            "on-click" = "pkill ${launcher} || ${launcher}";
            # "on-click-middle" = "exec default_wall";
            # "on-click-right" = "exec wallpaper_random";
            "tooltip" = false;
          };
          "custom/cava-internal" = {
            "exec" = "sleep 1s && cava-internal";
            "tooltip" = false;
          };
          "battery" = {
            "bat" = "BAT0";
            "interval" = 60;
            "states" = {
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{icon} {capacity}%";
            "format-alt" = "{icon} {capacity}% ({power} W)";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
            ];
            "max-length" = 25;
          };
          "disk" = {
            "path" = "/";
            "interval" = 180;
            "format" = "󰨣 {percentage_used}%";
          };
          "pulseaudio" = {
            "format" = "{icon} {volume}%";
            "format-bluetooth" = "{icon} {volume}%";
            "format-muted" = "󰝟";
            "format-icons" = {
              "headphone" = "";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [
                ""
                ""
                ""
              ];
            };
            "scroll-step" = 1;
            "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "ignored-sinks" = [ "Easy Effects Sink" ];
          };
          "clock" = {
            "format" = " {:%H:%M}";
            "format-alt" = " {:%A %d %B %Y (%R)}";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            "calendar" = {
              "mode" = "year";
              "mode-mon-col" = 3;
              "weeks-pos" = "right";
              "on-scroll" = 1;
              "on-click-right" = "mode";
              "format" = {
                "months" = "<span color='#ffead3'><b>{}</b></span>";
                "days" = "<span color='#ecc6d9'><b>{}</b></span>";
                "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
                "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
                "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            "actions" = {
              "on-click-right" = "mode";
              "on-click-forward" = "tz_up";
              "on-click-backward" = "tz_down";
              "on-scroll-up" = "shift_up";
              "on-scroll-down" = "shift_down";
            };
          };
          "memory" = {
            "interval" = 1;
            "format" = "󰻠 {percentage}%";
            "states" = {
              "warning" = 85;
            };
          };
          "cpu" = {
            "interval" = 1;
            "format" = "󰍛 {usage}%";
          };
          "mpd" = {
            "max-length" = 25;
            "format" = "<span foreground='#bb9af7'></span> {title}";
            "format-paused" = " {title}";
            "format-stopped" = "<span foreground='#bb9af7'></span>";
            "format-disconnected" = "";
            "on-click" = "mpc --quiet toggle";
            "on-click-right" = "mpc update; mpc ls | mpc add";
            "on-click-middle" = "kitty --class='ncmpcpp' ncmpcpp ";
            "on-scroll-up" = "mpc --quiet prev";
            "on-scroll-down" = "mpc --quiet next";
            "smooth-scrolling-threshold" = 5;
            "tooltip-format" = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
          };
          "network" = {
            "format-disconnected" = "";
            "format-ethernet" = " Connected!";
            "format-linked" = "󰖪 {essid} (No IP)";
            "format-wifi" = "󰖩 {essid}";
            "interval" = 1;
            "tooltip-format-wifi" = " {essid} ({signalStrength}%)\rIP: {ipaddr}\rUp: {bandwidthUpBits}\rDown: {bandwidthDownBits}\rSignal: {signaldBm} dBm\rFrequency: {frequency} GHz";
            "tooltip-format-ethernet" = " {ifname}\rIP: {ipaddr}\rUp: {bandwidthUpBits}\rDown: {bandwidthDownBits}";
            "tooltip-format-disconnected" = "Disconnected";
          };
          "custom/powermenu" = {
            "format" = "";
            "on-click" = "wlogout -p layer-shell";
            "tooltip" = false;
          };
          "tray" = {
            "icon-size" = 15;
            "spacing" = 5;
          };
        }
      ];
    };
  };
}
