{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.sway;
in
with lib;

{
  options.profiles.sway = {
    enable = mkEnableOption "Sway";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      layout = "fr";
      xkbVariant = "";
    };

    programs.dconf.enable = true;
    programs.xwayland.enable = true;
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = [ ];
    };

    xdg.portal = {
      enable = true;
      extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk ];
    };

    fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
      ];
      fontconfig.antialias = true;
    };

    environment.systemPackages = optional config.services.tailscale.enable pkgs.tailscale-systray;
  };
}
