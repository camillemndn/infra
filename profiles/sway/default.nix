{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.sway.enable {
  environment.systemPackages = lib.optional config.services.tailscale.enable pkgs.tailscale-systray;
}
