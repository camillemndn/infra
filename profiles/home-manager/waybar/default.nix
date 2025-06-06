{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.waybar;
  launcher = "fuzzel";
in

{
  options.programs.waybar.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ pavucontrol ];

    programs.waybar = {
      settings = [
        {
          layer = "top";
          position = "top";
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
          backlight = {
            format = "{icon} {percent}%";
            format-icons = [
              ""
              ""
            ];
          };
          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };
          bluetooth = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias} {device_battery_percentage}%";
            on-click = "STATE=`bluetoothctl show | grep Powered | awk '{print $2}'`; if [[ $STATE == 'yes' ]]; then bluetoothctl power off; else bluetoothctl power on; fi";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          };
          "custom/launcher" = {
            format = " ";
            on-click = "pkill ${launcher} || ${launcher}";
            # on-click-middle ="exec default_wall";
            # on-click-right ="exec wallpaper_random";
            tooltip = false;
          };
          "custom/cava-internal" = {
            exec = "sleep 1s && cava-internal";
            tooltip = false;
          };
          battery = {
            bat = "BAT0";
            interval = 60;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-alt = "{icon} {capacity}% ({power} W)";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            max-length = 25;
          };
          disk = {
            path = "/";
            interval = 180;
            format = "󰨣 {percentage_used}%";
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-muted = "󰝟";
            format-icons = {
              headphone = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            scroll-step = 1;
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right = "pavucontrol";
            ignored-sinks = [ "Easy Effects Sink" ];
          };
          clock = {
            format = " {:%H:%M}";
            format-alt = " {:L%A %d %B %Y (%R)}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-click-forward = "tz_up";
              on-click-backward = "tz_down";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };
          memory = {
            interval = 1;
            format = "󰻠 {percentage}%";
            states = {
              warning = 85;
            };
          };
          cpu = {
            interval = 1;
            format = "󰍛 {usage}%";
          };
          mpd = {
            max-length = 25;
            format = "<span foreground='#bb9af7'></span> {title}";
            format-paused = " {title}";
            format-stopped = "<span foreground='#bb9af7'></span>";
            format-disconnected = "";
            on-click = "mpc --quiet toggle";
            on-click-right = "mpc update; mpc ls | mpc add";
            on-click-middle = "kitty --class='ncmpcpp' ncmpcpp ";
            on-scroll-up = "mpc --quiet prev";
            on-scroll-down = "mpc --quiet next";
            smooth-scrolling-threshold = 5;
            tooltip-format = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
          };
          network = {
            format-disconnected = "";
            format-ethernet = " Connected!";
            format-linked = "󰖪 {essid} (No IP)";
            format-wifi = "󰖩 {essid}";
            interval = 1;
            tooltip-format-wifi = " {essid} ({signalStrength}%)\rIP: {ipaddr}\rUp: {bandwidthUpBits}\rDown: {bandwidthDownBits}\rSignal: {signaldBm} dBm\rFrequency: {frequency} GHz";
            tooltip-format-ethernet = " {ifname}\rIP: {ipaddr}\rUp: {bandwidthUpBits}\rDown: {bandwidthDownBits}";
            tooltip-format-disconnected = "Disconnected";
          };
          "custom/powermenu" = {
            format = "";
            on-click = "wlogout -p layer-shell";
            tooltip = false;
          };
          tray = {
            icon-size = 15;
            spacing = 5;
          };
        }
      ];

      style = builtins.readFile ./style.css;

      systemd = {
        enable = false;
        target = "graphical-session.target";
      };
    };
  };
}
