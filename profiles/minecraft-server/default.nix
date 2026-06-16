{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.minecraft-servers.enable {
  services.minecraft-servers = {
    eula = true;

    servers.vanilla = {
      enable = true;
      openFirewall = true;

      package = pkgs.paperServers.paper.override {
        version = "26.2-rc-2-9";
        url = "https://fill-data.papermc.io/v1/objects/52d1ef0ed78597f5d4bcf1067788cfd009a15f97dc9633fcef2ef10cadae38e1/paper-26.2-rc-2-9.jar";
        sha256 = "52d1ef0ed78597f5d4bcf1067788cfd009a15f97dc9633fcef2ef10cadae38e1";
      };

      jvmOpts = "-Xms4G -Xmx4G -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";

      serverProperties = {
        online-mode = false;
        server-port = 25566;
        white-list = true;
      };

      files = {
        "whitelist.json" = config.age.secrets.minecraft-whitelist.path;
        "ops.json" = config.age.secrets.minecraft-ops.path;
      };

      lazymc = {
        enable = true;
        config = {
          public.address = "0.0.0.0:25565";
          server.wake_whitelist = true;
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

  environment.systemPackages = [ config.services.minecraft-servers.servers.vanilla.package ];
}
