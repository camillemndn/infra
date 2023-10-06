{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.boot.initrd.clevis;
  supportedFs = [ "zfs" "bcachefs" ];
in
{

  meta.maintainers = with maintainers; [ julienmalka camillemndn ];

  options = {
    boot.initrd.clevis.enable = mkEnableOption (lib.mdDoc "Clevis in initrd");


    boot.initrd.clevis.package = mkOption {
      type = types.package;
      default = pkgs.clevis;
      defaultText = "pkgs.clevis";
      description = lib.mdDoc "Clevis package";
    };

    boot.initrd.clevis.devices = mkOption {
      description = "Encrypted devices that need to be unlocked at boot using Clevis";
      default = { };
      type = types.attrsOf (types.submodule ({
        options.secretFile = mkOption {
          description = lib.mdDoc "Clevis JWE secret file used to decrypt the device at boot";
          type = types.path;
        };
      }));
    };

    boot.initrd.clevis.useTang = mkOption {
      description = "Wether the clevis secret used to decrypt the devices are binded to a Tang server";
      default = false;
      type = types.bool;
    };

  };

  config = mkIf cfg.enable {

    # Implementation of clevis unlocking for the supported filesystems are located directly in the respective modules.


    assertions = (attrValues (mapAttrs
      (device: _: {
        assertion = (any (fs: fs.device == device && (elem fs.fsType supportedFs)) config.system.build.fileSystems) || (hasAttr device config.boot.initrd.luks.devices);
        message = ''
          No filesystem or LUKS device with the name ${name} is declared in your configuration ${trace config.fileSystems device}
        '';
      })
      cfg.devices));


    warnings =
      if cfg.useTang && !config.boot.initrd.network.enable && !config.boot.initrd.systemd.network.enable
      then [ "In order to use a Tang binded secret you must configure networking in initrd" ]
      else [ ];

    boot.initrd = {
      extraUtilsCommands = ''
        copy_bin_and_libs ${cfg.package}/bin/.clevis-wrapped
        mv $out/bin/{.clevis-wrapped,clevis}
        copy_bin_and_libs ${cfg.package}/bin/clevis-decrypt
        copy_bin_and_libs ${cfg.package}/bin/clevis-decrypt-tang
        copy_bin_and_libs ${pkgs.jose}/bin/jose
        copy_bin_and_libs ${pkgs.curl}/bin/curl
        copy_bin_and_libs ${pkgs.bash}/bin/bash
        substituteInPlace $out/bin/clevis --replace "${pkgs.bash}/bin/bash" "/bin/bash"
        substituteInPlace $out/bin/clevis-decrypt --replace "${pkgs.bash}/bin/bash" "/bin/bash"
        substituteInPlace $out/bin/clevis-decrypt --replace "${pkgs.coreutils}/bin/cat" "/bin/cat"
        substituteInPlace $out/bin/clevis-decrypt-tang --replace "${pkgs.bash}/bin/bash" "/bin/bash"
        substituteInPlace $out/bin/clevis-decrypt-tang --replace "${pkgs.coreutils}/bin/cat" "/bin/cat"
      '';

      secrets = lib.mapAttrs' (name: value: nameValuePair "/etc/clevis/${name}.jwe" value.secretFile) cfg.devices;

      systemd = {
        extraBin.clevis = "${cfg.package}/bin/clevis";
        extraBin.cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
        extraBin.curl = "${pkgs.curl}/bin/curl";
        extraBin.ip = "${pkgs.busybox}/bin/ip";
        extraBin.sed = "${pkgs.busybox}/bin/sed";
        extraBin.grep = "${pkgs.busybox}/bin/grep";
        extraBin.jose = "${pkgs.jose}/bin/jose";
        extraBin.luksmeta = "${pkgs.luksmeta}/bin/luksmeta";

        storePaths = [
          cfg.package
          "${pkgs.busybox}"
          "${pkgs.luksmeta}/bin/luksmeta"
          "${pkgs.jose}/bin/jose"
          "${pkgs.curl}/bin/curl"
          "${pkgs.tpm2-tools}/bin/tpm2_createprimary"
          "${pkgs.tpm2-tools}/bin/tpm2_flushcontext"
          "${pkgs.tpm2-tools}/bin/tpm2_load"
          "${pkgs.tpm2-tools}/bin/tpm2_unseal"
        ];
      };
    };
  };
}
