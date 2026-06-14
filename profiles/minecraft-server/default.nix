{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.minecraft-server.enable {
  services.minecraft-server = {
    eula = true;
    package =
      (pkgs.papermc.override {
        jre = pkgs.jdk25;
        version = "26.1.2-70";
        hash = "sha256-bFnu/idS+X7nn4OtCmH+FIZaCXbkrAZZf1PebESv1sU=";
      }).overrideAttrs
        (_: {
          src = pkgs.fetchurl {
            url = "https://fill-data.papermc.io/v1/objects/6c59eefe2752f97ee79f83ad0a61fe14865a0976e4ac06597f53de6c44afd6c5/paper-26.1.2-70.jar";
            hash = "sha256-bFnu/idS+X7nn4OtCmH+FIZaCXbkrAZZf1PebESv1sU=";
          };
        });
    jvmOpts = "-Xms4G -Xmx4G -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15";
  };

  systemd.services.minecraft-server.wantedBy = lib.mkForce [ ];

  environment.systemPackages = [ config.services.minecraft-server.package ];
}
