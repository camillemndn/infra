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
    user = "julien";
  };

  #
  # User configuration
  #

  users.users."julien" = {
    isNormalUser = true;
    description = "Julien";
    hashedPassword = "$6$8RP9D.PjdHaFGGz7$CLWZH8ccKy1I5D.k9he9BMx2Q/qr.KAYVrLhn6r7V.6M6HV7JPaetP3nFho3nSLbBbA1gpj0KUqHqLaresZzQ1";
    extraGroups = [
      "dialout"
      "feedbackd"
      "networkmanager"
      "video"
      "wheel"
    ];
  };
  services.openssh.enable = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "julien" ];

      substituters = [
        "https://cache.mondon.xyz?priority=45"
        "https://cache2.mondon.xyz?priority=45"
      ];

      trusted-public-keys = [
        "cache.mondon.xyz:6o1j93GkK5gj0PfYouSA4WPAEEnOuPGTebLCWc/jKfQ="
        "cache2.mondon.xyz:8zCLL6cuq3rX66LpesMMQRticIrMsewHXzl8NmPUvfs="
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
