{
  config,
  lib,
  pkgs,
  ...
}:

let
  paper = pkgs.paperServers.paper-26_1_2;

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

  # idx ∈ 1..N: server-port = 25580+idx, lazymc loopback port = 25570+idx
  mkVanillaServer = idx: {
    enable = true;
    openFirewall = false;
    package = paper;
    jvmOpts = paperJvm;
    serverProperties = {
      online-mode = false;
      server-port = 25580 + idx;
      white-list = true;
    };
    files = whitelistFiles;
    lazymc = {
      enable = true;
      config = {
        public.address = "127.0.0.1:${toString (25570 + idx)}";
        server.wake_whitelist = true;
        time.sleep_after = 300;
      };
    };
  };

  velocityToml = (pkgs.formats.toml { }).generate "velocity.toml" {
    config-version = "2.7";
    bind = "0.0.0.0:25565";
    motd = "<bold>mndn minecraft</bold>";
    show-max-players = 100;
    online-mode = false;
    player-info-forwarding-mode = "none";
    servers = {
      v1 = "127.0.0.1:25571";
      v2 = "127.0.0.1:25572";
      v3 = "127.0.0.1:25573";
      v4 = "127.0.0.1:25574";
      cobbleverse = "127.0.0.1:25575";
      try = [ "v1" ];
    };
    forced-hosts = {
      "v1.mc.mndn.fr" = [ "v1" ];
      "v2.mc.mndn.fr" = [ "v2" ];
      "v3.mc.mndn.fr" = [ "v3" ];
      "v4.mc.mndn.fr" = [ "v4" ];
      "cobbleverse.mc.mndn.fr" = [ "cobbleverse" ];
    };
    advanced = {
      compression-threshold = 256;
      compression-level = -1;
    };
  };
in

lib.mkIf config.services.minecraft-servers.enable {
  services.minecraft-servers = {
    eula = true;

    servers = {
      v1 = mkVanillaServer 1;
      v2 = mkVanillaServer 2;
      v3 = mkVanillaServer 3;
      v4 = mkVanillaServer 4;

      # Cobbleverse 1.7.31 — Fabric 1.21.1, Pokémon adventure (Cobblemon).
      # First nixos-rebuild will fail with the real packHash; paste it into
      # `cobbleverse.packHash` above and rebuild. Then flip enable = true.
      cobbleverse = {
        enable = true;
        openFirewall = false;
        package = pkgs.fabricServers.fabric-1_21_1;
        jvmOpts = "-Xms4G -Xmx8G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";
        serverProperties = {
          online-mode = false;
          server-port = 25585;
          white-list = true;
        };
        files = whitelistFiles;
        symlinks = {
          "mods" = "${cobbleverse}/mods";
          "config" = "${cobbleverse}/config";
          "defaultconfigs" = "${cobbleverse}/defaultconfigs";
        };
        lazymc = {
          enable = true;
          config = {
            public.address = "127.0.0.1:25575";
            server.wake_whitelist = true;
            time.sleep_after = 600; # modpack: longer idle before sleep
            time.minimum_online_time = 60; # avoid rapid sleep/wake while booting
          };
        };
      };

      proxy = {
        enable = true;
        openFirewall = true;
        package = pkgs.velocityServers.velocity;
        jvmOpts = "-Xms512M -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";
        serverProperties = { }; # Velocity ignores server.properties
        files."velocity.toml" = velocityToml;
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

  environment.systemPackages = [ config.services.minecraft-servers.servers.v1.package ];
}
