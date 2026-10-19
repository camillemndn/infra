{
  config,
  inputs,
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
    "ops.json" = config.age.secrets.minecraft-ops.path;
    "whitelist.json" = config.age.secrets.minecraft-whitelist.path;
  };

  # The .mrpack has mode-0000 shader files that break cp: chmod after unzip.
  cobbleverse =
    (pkgs.fetchModrinthModpack {
      packHash = "sha256-0PlMdYFWbRe06ARNjbLYmEFh2HsEiwyueHWLkNAU3T8=";
      side = "server";
      url = "https://cdn.modrinth.com/data/Jkb29YJU/versions/DN77rBht/COBBLEVERSE%201.7.31.mrpack";
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
      files = whitelistFiles;
      jvmOpts = paperJvm;

      lazymc = {
        enable = true;

        config = {
          public = {
            address = if public then "0.0.0.0:25565" else "127.0.0.1:${toString (25570 + idx)}";
            version = lib.head (lib.splitString "-" package.version);
          };

          server = {
            freeze_process = false;
            wake_whitelist = true;
          };

          time.sleep_after = 180;
        };
      };

      openFirewall = public;

      serverProperties = {
        motd = "Un nouveau monde";
        online-mode = false;
        server-port = 25580 + idx;
        white-list = true;
      };
    };
in

{
  imports = [ "${inputs.nix-minecraft}/modules/minecraft-servers.nix" ];

  age = {
    secrets = {
      minecraft-ops = {
        file = ./ops.json.age;
        group = "minecraft";
        mode = "0440";
        owner = "minecraft";
      };

      minecraft-whitelist = {
        file = ./whitelist.json.age;
        group = "minecraft";
        mode = "0440";
        owner = "minecraft";
      };
    };
  };

  nixpkgs.overlays = [ (import "${inputs.nix-minecraft}/overlay.nix") ];

  services = {
    minecraft-servers = {
      enable = true;
      eula = true;

      managementSystem = {
        systemd-socket.enable = true;
        tmux.enable = false;
      };

      servers = {
        cobbleverse = rec {
          enable = enableIf "cobbleverse";

          # Fabric mods rewrite config/: copied into the data dir, reset on restart.
          files = whitelistFiles // {
            "config" = "${cobbleverse}/config";
          };

          jvmOpts = "-Xms4G -Xmx8G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

          lazymc = {
            enable = true;

            config = {
              join.hold.timeout = 60;

              public = {
                address = "0.0.0.0:25565";
                version = lib.head (lib.splitString "-" package.version);
              };

              server = {
                freeze_process = false;
                wake_whitelist = true;
              };

              time.sleep_after = 300;
            };
          };

          openFirewall = true;
          package = pkgs.fabricServers.fabric-1_21_1;

          serverProperties = {
            motd = "Un monde Pokémon";
            online-mode = false;
            server-port = 25585;
            white-list = true;
          };

          symlinks = {
            "datapacks" = "${cobbleverse}/datapacks";
            "mods" = "${cobbleverse}/mods";
            "resourcepacks" = "${cobbleverse}/resourcepacks";
          };
        };

        proxy = {
          enable = enableIf "velocity";

          files."velocity.toml" = (pkgs.formats.toml { }).generate "velocity.toml" {
            advanced = {
              compression-level = -1;
              compression-threshold = 256;
            };

            bind = "0.0.0.0:25565";
            config-version = "2.7";

            forced-hosts = {
              "v1.mc.mndn.fr" = [ "v1" ];
              "v2.mc.mndn.fr" = [ "v2" ];
              "v3.mc.mndn.fr" = [ "v3" ];
              "v4.mc.mndn.fr" = [ "v4" ];
            };

            motd = "Une porte sur des mondes";
            online-mode = false;
            player-info-forwarding-mode = "none";

            servers = {
              try = [ "v1" ];
              v1 = "127.0.0.1:25571";
              v2 = "127.0.0.1:25572";
              v3 = "127.0.0.1:25573";
              v4 = "127.0.0.1:25574";
            };

            show-max-players = 100;
          };

          jvmOpts = "-Xms512M -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";
          openFirewall = true;
          package = pkgs.velocityServers.velocity;
          serverProperties = { }; # Velocity ignores server.properties
        };

        v1 = mkVanillaServer {
          enable = enableIf "velocity";
          idx = 1;
          package = pkgs.paperServers.paper-26_2;
        };

        v2 = mkVanillaServer {
          enable = enableIf "velocity";
          idx = 2;
          package = pkgs.paperServers.paper-26_2;
        };

        v3 = mkVanillaServer {
          enable = enableIf "velocity";
          idx = 3;
          package = pkgs.paperServers.paper-26_2;
        };

        v4 = mkVanillaServer {
          enable = enableIf "velocity";
          idx = 4;
          package = pkgs.paperServers.paper-26_2;
        };
      };
    };
  };
}
