{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.sway.enable {
  services.xserver = {
    enable = true;
    xkb = {
      layout = "fr";
      variant = "";
    };
  };

  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  programs.sway = {
    wrapperFeatures.gtk = true;
    extraPackages = [ ];
  };

  environment.systemPackages = lib.optional config.services.tailscale.enable pkgs.tailscale-systray;
}
