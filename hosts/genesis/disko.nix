{ inputs, ... }:

{
  imports = [ "${inputs.disko}/module.nix" ];

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-WDC_PC_SN530_SDBPTPZ-1T00-1002_211142450407";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          priority = 1;
          size = "512M";
          type = "EF00";
          device = "/dev/disk/by-uuid/A48C-7D48";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        root = {
          priority = 2;
          end = "-34G";
          device = "/dev/disk/by-uuid/d0de046c-c584-4761-a3cb-66fc7a1802b8";

          content = {
            type = "luks";
            name = "luks-d0de046c-c584-4761-a3cb-66fc7a1802b8";
            settings.crypttabExtraOpts = [ "tpm2-device=auto" ];

            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              device = "/dev/disk/by-uuid/7bb7a74c-66f3-4d32-8502-edf64f52e23e";
            };
          };
        };

        swap = {
          priority = 3;
          size = "100%";
          device = "/dev/disk/by-uuid/dd5289a3-7499-4efe-8354-2bf713b672df";

          content = {
            type = "luks";
            name = "luks-dd5289a3-7499-4efe-8354-2bf713b672df";
            settings.keyFile = "/crypto_keyfile.bin";

            content = {
              type = "swap";
              device = "/dev/disk/by-uuid/985173da-9c6d-46e0-a04b-bbba9966f315";
            };
          };
        };
      };
    };
  };
}
