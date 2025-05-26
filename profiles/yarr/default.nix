{ config, lib, ... }:

lib.mkIf config.services.yarr.enable {
  services.nginx.virtualHosts."feeds.kms".port = 7070;

  services.yarr.authFilePath = config.age.secrets.yarr-auth.path;

  age.secrets.yarr-auth = {
    owner = "yarr";
    file = ./auth.age;
  };
}
