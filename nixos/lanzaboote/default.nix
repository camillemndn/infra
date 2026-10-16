{ config, lib, ... }:

lib.mkIf config.boot.lanzaboote.enable {
  boot.lanzaboote = {
    configurationLimit = lib.mkDefault 5;
    pkiBundle = lib.mkDefault "/var/lib/sbctl";
  };
}
