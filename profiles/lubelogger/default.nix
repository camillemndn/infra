{ config, lib, ... }:

lib.mkIf config.services.lubelogger.enable {
  services = {
    lubelogger = {
      settings = {
        EnableAuth = "true";
        UserNameHash = "566396870954ab2080f4aeb0d62e709d1bf3ca8ffa504cd55ba3369e23fe73cb";
        UserPasswordHash = "c6b5f795786a4dc674a1c8dce376e4baaf984c1e47a7e583b6d5f3a22c0af345";
        UseDarkMode = "true";
        Kestrel__Endpoints__Http__Url = "http://localhost:5003";
      };
    };

    nginx.virtualHosts."vehicles.kms".port = 5003;
  };
}
