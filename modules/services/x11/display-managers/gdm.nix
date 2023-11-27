{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.xserver.displayManager;
in

{
  options.services.xserver.displayManager.gdm.extraConfig = mkOption {
    type = types.lines;
    default = "";
    example = ''
      [org/gnome/desktop/interface]
      cursor-size=40
    '';
    description = ''
      Set addition configuration for dconf.
    '';
  };

  config.programs.dconf.profiles.gdm =
    let
      customDconf = pkgs.writeTextFile {
        name = "gdm-dconf";
        destination = "/dconf/gdm-custom";
        text = optionalString (!cfg.gdm.autoSuspend) ''
          [org/gnome/settings-daemon/plugins/power]
          sleep-inactive-ac-type='nothing'
          sleep-inactive-battery-type='nothing'
          sleep-inactive-ac-timeout=0
          sleep-inactive-battery-timeout=0
        '' + cfg.gdm.extraConfig;
      };

      customDconfDb = pkgs.stdenv.mkDerivation {
        name = "gdm-dconf-db";
        buildCommand = ''
          ${pkgs.dconf}/bin/dconf compile $out ${customDconf}/dconf
        '';
      };
    in
    mkForce (pkgs.stdenv.mkDerivation {
      name = "dconf-gdm-profile";
      buildCommand = ''
        # Check that the GDM profile starts with what we expect.
        if [ $(head -n 1 ${pkgs.gnome.gdm}/share/dconf/profile/gdm) != "user-db:user" ]; then
          echo "GDM dconf profile changed, please update gdm.nix"
          exit 1
        fi
        # Insert our custom DB behind it.
        sed '2ifile-db:${customDconfDb}' ${pkgs.gnome.gdm}/share/dconf/profile/gdm > $out
      '';
    });
}
