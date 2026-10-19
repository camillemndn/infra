{ inputs, ... }:

{
  imports = [ "${inputs.disko}/module.nix" ];

  disko.devices.disk.main = {
    content = {
      partitions = {
        ESP = {
          content = {
            format = "vfat";
            mountpoint = "/boot";
            type = "filesystem";
          };

          device = "/dev/disk/by-uuid/A48C-7D48";
          priority = 1;
          size = "512M";
          type = "EF00";
        };

        root = {
          content = {
            content = {
              device = "/dev/disk/by-uuid/7bb7a74c-66f3-4d32-8502-edf64f52e23e";
              format = "ext4";
              mountpoint = "/";
              type = "filesystem";
            };

            name = "luks-d0de046c-c584-4761-a3cb-66fc7a1802b8";
            type = "luks";
          };

          device = "/dev/disk/by-uuid/d0de046c-c584-4761-a3cb-66fc7a1802b8";
          end = "-34G";
          priority = 2;
        };

        swap = {
          content = {
            content = {
              device = "/dev/disk/by-uuid/985173da-9c6d-46e0-a04b-bbba9966f315";
              type = "swap";
            };

            name = "luks-dd5289a3-7499-4efe-8354-2bf713b672df";
            settings.keyFile = "/crypto_keyfile.bin";
            type = "luks";
          };

          device = "/dev/disk/by-uuid/dd5289a3-7499-4efe-8354-2bf713b672df";
          priority = 3;
          size = "100%";
        };
      };

      type = "gpt";
    };

    device = "/dev/disk/by-id/nvme-WDC_PC_SN530_SDBPTPZ-1T00-1002_211142450407";
    type = "disk";
  };
}
