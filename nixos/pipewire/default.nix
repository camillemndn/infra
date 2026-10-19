{ config, lib, ... }:

lib.mkIf config.services.pipewire.enable {
  security.rtkit.enable = lib.mkDefault true;

  services.pipewire = {
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };

    pulse.enable = lib.mkDefault true;
  };
}
