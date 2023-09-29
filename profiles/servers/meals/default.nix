{ config, lib, ... }:

let
  cfg = config.profiles.meals;
in
with lib;

{
  options.profiles.meals = {
    enable = mkEnableOption "Meals";
  };

  config = mkIf cfg.enable {
    services.tandoor-recipes = {
      enable = true;
      port = 8180;
    };

    services.nginx.virtualHosts."meals.mondon.xyz".port = 8180;
  };
}
