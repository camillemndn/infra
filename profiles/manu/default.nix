{ config, lib, ... }:

let
  cfg = config.profiles.manu;
in
with lib;

{
  options.profiles.manu = {
    enable = mkEnableOption "Manu user";
  };

  config = mkIf cfg.enable {
    users.users.manu = {
      isNormalUser = true;
      description = "Manu";
    };

    services.openssh.extraConfig = ''
      Match User manu
      PasswordAuthentication yes 
    '';
  };
}
