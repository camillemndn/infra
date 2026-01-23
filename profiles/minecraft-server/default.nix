{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.minecraft-server.enable {
  services.minecraft-server = {
    eula = true;
    package = pkgs.papermc;
    jvmOpts = "-Xms4G -Xmx4G -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";
  };

  systemd.services.minecraft-server.wantedBy = lib.mkForce [ ];
}
