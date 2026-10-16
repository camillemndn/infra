{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.printing.enable {
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    printing.drivers = with pkgs; [
      cups-browsed
      cups-filters
      gutenprint
    ];
  };
}
