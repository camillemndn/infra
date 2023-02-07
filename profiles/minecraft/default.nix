{ config, lib, ... }:

let
  cfg = config.profiles.minecraft;
in
with lib;

{
  options.profiles.minecraft = {
    enable = mkEnableOption "Activate my Minecraft server";
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      openFirewall = true;
      eula = true;
      declarative = true;
      serverProperties = {
        white-list = true;
        motd = "Bienvenid@s en el ZEPPELIN";
      };
      whitelist = {
        TitoManwe = "a83ccf9c-0550-4b8b-be17-c0d3eabd0f13";
        Zalaban = "1ad93013-7601-4780-a73f-707e5677ece4";
      };
    };
  };
}
