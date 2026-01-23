{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.desktopManager.plasma6.enable {
  environment = {
    plasma6.excludePackages = [ pkgs.kdePackages.konsole ];
    systemPackages = with pkgs.kdePackages; [ kclock ];
  };

  programs.partition-manager.enable = true;
}
