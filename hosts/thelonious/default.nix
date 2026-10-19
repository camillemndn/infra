{ pkgs, ... }:

{
  home-manager.users.camille = {
    programs.vscodium.enable = true;
    home.stateVersion = "23.11";
  };

  programs = {
    dms-shell.enable = true;
    nixvim.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    logind.settings.Login.KillUserProcesses = true;
    power-profiles-daemon.enable = false;
  };

  stylix.enable = true;

  users.users.camille.packages = with pkgs; [
    # Desk
    pdftocgen
  ];

  system.stateVersion = "23.11";
}
