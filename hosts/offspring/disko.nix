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

          device = "/dev/disk/by-uuid/F33A-753F";
          priority = 3;
          size = "100%";
          type = "EF00";
        };

        root = {
          content = {
            format = "ext4";
            mountpoint = "/";
            type = "filesystem";
          };

          device = "/dev/disk/by-uuid/34223ccd-07a5-4c1c-b2d6-f49246dcb9a8";
          end = "-4G";
          priority = 1;
          type = "6A898CC3-1DD2-11B2-99A6-080020736631";
        };

        swap = {
          content.type = "swap";
          device = "/dev/disk/by-uuid/0f02375d-b47b-45c7-a0d3-391c39cb2570";
          end = "-512M";
          priority = 2;
          type = "8200";
        };
      };

      type = "gpt";
    };

    device = "/dev/disk/by-id/scsi-3609bcf57116c481d8008b8c5e218697a";
    type = "disk";
  };
}
