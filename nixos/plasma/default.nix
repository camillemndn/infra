{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.desktopManager.plasma6.enable {
  environment = {
    plasma6.excludePackages = [ pkgs.kdePackages.konsole ];

    systemPackages = with pkgs; [
      kdePackages.filelight
      kdePackages.kate
      kdePackages.kclock
      kdePackages.skanlite
      libreoffice-qt-fresh
    ];
  };

  programs.partition-manager.enable = true;

  # The DMS greeter replaces SDDM where it is enabled.
  services.displayManager.sddm = lib.mkIf (!config.services.displayManager.dms-greeter.enable) {
    enable = lib.mkDefault true;
    autoLogin.relogin = lib.mkDefault true;
    wayland.enable = lib.mkDefault true;
  };
}
