{ config, lib, pkgs, ... }:

{
  networking.hostName = "pinkfloyd";

  #
  # Opinionated defaults
  #

  # Use Network Manager
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Use PulseAudio
  hardware.pulseaudio.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Bluetooth audio
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable power management options
  powerManagement.enable = true;

  # It's recommended to keep enabled on these constrained devices
  zramSwap.enable = true;

  # Auto-login for phosh
  services.xserver.desktopManager.phosh = {
    user = "camille";
  };
  services.openssh.enable = true;

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [ vlc ];
  #
  # User configuration
  #

  users.users."camille" = {
    hashedPassword = "$y$j9T$xLuhy428hvJuTbKuJcbim0$EchthidZtxYp7QjZNrQt3SqdZ0mP2htnDiJFLuLNey7";
    extraGroups = [
      "dialout"
      "feedbackd"
      "video"
    ];
  };

  networking.nftables.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
