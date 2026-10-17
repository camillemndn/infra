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
    };

    printing.drivers = with pkgs; [
      cups-browsed
      cups-filters
      gutenprint
    ];
  };
}
