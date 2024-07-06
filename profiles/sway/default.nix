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

  xdg.portal = {
    enable = true;
    extraPortals = lib.mkForce [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
        ];
      })
    ];
    fontconfig.antialias = true;
  };

  environment.systemPackages = lib.optional config.services.tailscale.enable pkgs.tailscale-systray;
}
