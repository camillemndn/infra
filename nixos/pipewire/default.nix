{ config, lib, ... }:

lib.mkIf config.services.pipewire.enable {
  services.pipewire = {
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };
    pulse.enable = lib.mkDefault true;
  };

  security.rtkit.enable = lib.mkDefault true;
}
