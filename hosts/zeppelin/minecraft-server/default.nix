{
  config,
  lib,
  pkgs,
  ...
}:

let
  # What listens on TCP 25565, one group at a time:
  #   "velocity"    Velocity + v1/v2/v3 (paper 26.1.2) + v4 (paper 26.2)
  #   "cobbleverse" Fabric 1.21.1 modpack, no proxy
  mode = "velocity";
  enableIf = m: mode == m;

  paperJvm = "-Xms4G -Xmx4G -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";

  whitelistFiles = {
    "whitelist.json" = config.age.secrets.minecraft-whitelist.path;
    "ops.json" = config.age.secrets.minecraft-ops.path;
  };

  # The .mrpack has mode-0000 shader files that break cp: chmod after unzip.
  cobbleverse =
    (pkgs.fetchModrinthModpack {
      url = "https://cdn.modrinth.com/data/Jkb29YJU/versions/DN77rBht/COBBLEVERSE%201.7.31.mrpack";
      packHash = "sha256-0PlMdYFWbRe06ARNjbLYmEFh2HsEiwyueHWLkNAU3T8=";
      side = "server";
    }).overrideAttrs
      (old: {
        buildPhase =
          builtins.replaceStrings
            [ ''if [ "$(stat -c '%a' "$index_json_path")" == 0 ]; then'' ]
            [ "if true; then" ]
            old.buildPhase;
      });

  # Server port 25580+idx, lazymc 25570+idx, or 0.0.0.0:25565 when public.
  mkVanillaServer =
    {
      idx,
      package,
      enable,
      public ? false,
    }:
    {
      inherit enable package;
      openFirewall = public;
      jvmOpts = paperJvm;
      serverProperties = {
        motd = "Un nouveau monde";
        online-mode = false;
        server-port = 25580 + idx;
        white-list = true;
      };
      files = whitelistFiles;
      lazymc = {
        enable = true;
        config = {
          public = {
            address = if public then "0.0.0.0:25565" else "127.0.0.1:${toString (25570 + idx)}";
            version = lib.head (lib.splitString "-" package.version);
          };
          server = {
            wake_whitelist = true;
            freeze_process = false;
          };
          time.sleep_after = 180;
        };
      };
    };
in

{
  services = {
    minecraft-servers = {
      enable = true;
      eula = true;
      managementSystem = {
        tmux.enable = false;
        systemd-socket.enable = true;
      };

      servers = {
        v1 = mkVanillaServer {
          idx = 1;
          package = pkgs.paperServers.paper-26_2;
          enable = enableIf "velocity";
        };

        v2 = mkVanillaServer {
          idx = 2;
          package = pkgs.paperServers.paper-26_2;
          enable = enableIf "velocity";
        };

        v3 = mkVanillaServer {
          idx = 3;
          package = pkgs.paperServers.paper-26_2;
          enable = enableIf "velocity";
        };

        v4 = mkVanillaServer {
          idx = 4;
          package = pkgs.paperServers.paper-26_2;
          enable = enableIf "velocity";
        };

        cobbleverse = rec {
          enable = enableIf "cobbleverse";
          openFirewall = true;
          package = pkgs.fabricServers.fabric-1_21_1;
          jvmOpts = "-Xms4G -Xmx8G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";
          serverProperties = {
            motd = "Un monde Pokémon";
            online-mode = false;
            server-port = 25585;
            white-list = true;
          };
          # Fabric mods rewrite config/: copied into the data dir, reset on restart.
          files = whitelistFiles // {
            "config" = "${cobbleverse}/config";
          };
          symlinks = {
            "mods" = "${cobbleverse}/mods";
            "datapacks" = "${cobbleverse}/datapacks";
            "resourcepacks" = "${cobbleverse}/resourcepacks";
          };
          lazymc = {
            enable = true;
            config = {
              public = {
                address = "0.0.0.0:25565";
                version = lib.head (lib.splitString "-" package.version);
              };
              join.hold.timeout = 60;
              server = {
                wake_whitelist = true;
                freeze_process = false;
              };
              time.sleep_after = 300;
            };
          };
        };

        proxy = {
          enable = enableIf "velocity";
          openFirewall = true;
          package = pkgs.velocityServers.velocity;
          jvmOpts = "-Xms512M -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";
          serverProperties = { }; # Velocity ignores server.properties
          files."velocity.toml" = (pkgs.formats.toml { }).generate "velocity.toml" {
            config-version = "2.7";
            bind = "0.0.0.0:25565";
            motd = "Une porte sur des mondes";
            show-max-players = 100;
            online-mode = false;
            player-info-forwarding-mode = "none";
            servers = {
              v1 = "127.0.0.1:25571";
              v2 = "127.0.0.1:25572";
              v3 = "127.0.0.1:25573";
              v4 = "127.0.0.1:25574";
              try = [ "v1" ];
            };
            forced-hosts = {
              "v1.mc.mndn.fr" = [ "v1" ];
              "v2.mc.mndn.fr" = [ "v2" ];
              "v3.mc.mndn.fr" = [ "v3" ];
              "v4.mc.mndn.fr" = [ "v4" ];
            };
            advanced = {
              compression-threshold = 256;
              compression-level = -1;
            };
          };
        };
      };
    };
  };

  age = {
    secrets = {
      minecraft-whitelist = {
        file = ./whitelist.json.age;
        owner = "minecraft";
        group = "minecraft";
        mode = "0440";
      };
      minecraft-ops = {
        file = ./ops.json.age;
        owner = "minecraft";
        group = "minecraft";
        mode = "0440";
      };
    };
  };

}
