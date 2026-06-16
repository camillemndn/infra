{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Flip this to swap what listens on TCP 25565. Only one server may bind
  # the public port at a time; the unmatched options resolve to enable=false.
  #
  #   "velocity"   — Velocity proxy + v1/v2/v3 paper backends (loopback)
  #   "v4"         — single paper 26.2-rc-2 server, no proxy
  #   "cobbleverse" — single Fabric 1.21.1 modpack server, no proxy
  mode = "v4";
  enableIf = m: mode == m;

  paper-26-1 = pkgs.paperServers.paper-26_1_2;
  paper-26-2 = pkgs.paperServers.paper.override {
    version = "26.2-rc-2-9";
    url = "https://fill-data.papermc.io/v1/objects/52d1ef0ed78597f5d4bcf1067788cfd009a15f97dc9633fcef2ef10cadae38e1/paper-26.2-rc-2-9.jar";
    sha256 = "52d1ef0ed78597f5d4bcf1067788cfd009a15f97dc9633fcef2ef10cadae38e1";
  };

  paperJvm = "-Xms4G -Xmx4G -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";

  whitelistFiles = {
    "whitelist.json" = config.age.secrets.minecraft-whitelist.path;
    "ops.json" = config.age.secrets.minecraft-ops.path;
  };

  # Cobbleverse's .mrpack has shader files with mode 0000, which break the
  # default builder's cp. Force chmod after unzip via a tiny replaceStrings
  # patch on the buildPhase.
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

  # idx ∈ 1..N: server-port = 25580+idx, lazymc loopback port = 25570+idx.
  # When `public` is true, lazymc binds 0.0.0.0:25565 instead.
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
          public.address = if public then "0.0.0.0:25565" else "127.0.0.1:${toString (25570 + idx)}";
          server.wake_whitelist = true;
          time.sleep_after = 300;
        };
      };
    };
in

lib.mkIf config.services.minecraft-servers.enable {
  services.minecraft-servers = {
    eula = true;

    servers = {
      v1 = mkVanillaServer {
        idx = 1;
        package = paper-26-1;
        enable = enableIf "velocity";
      };
      v2 = mkVanillaServer {
        idx = 2;
        package = paper-26-1;
        enable = enableIf "velocity";
      };
      v3 = mkVanillaServer {
        idx = 3;
        package = paper-26-1;
        enable = enableIf "velocity";
      };
      v4 = mkVanillaServer {
        idx = 4;
        package = paper-26-2;
        enable = enableIf "v4";
        public = true;
      };

      cobbleverse = {
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
        # config/ must be writable: many Fabric mods rewrite their config
        # at startup. Copy it into the data dir (nix-minecraft deletes the
        # copy on stop, restoring known-good state from the store on restart).
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
            public.address = "0.0.0.0:25565";
            server.wake_whitelist = true;
            time.sleep_after = 600;
            time.minimum_online_time = 60;
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
            try = [ "v1" ];
          };
          forced-hosts = {
            "v1.mc.mndn.fr" = [ "v1" ];
            "v2.mc.mndn.fr" = [ "v2" ];
            "v3.mc.mndn.fr" = [ "v3" ];
          };
          advanced = {
            compression-threshold = 256;
            compression-level = -1;
          };
        };
      };
    };
  };

  age.secrets.minecraft-whitelist = {
    file = ./whitelist.json.age;
    owner = "minecraft";
    group = "minecraft";
    mode = "0440";
  };

  age.secrets.minecraft-ops = {
    file = ./ops.json.age;
    owner = "minecraft";
    group = "minecraft";
    mode = "0440";
  };

  environment.systemPackages = [
    (
      if mode == "cobbleverse" then
        pkgs.fabricServers.fabric-1_21_1
      else if mode == "v4" then
        paper-26-2
      else
        paper-26-1
    )
  ];
}
