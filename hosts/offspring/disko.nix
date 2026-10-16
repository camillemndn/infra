{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/scsi-3609bcf57116c481d8008b8c5e218697a";

    content = {
      type = "gpt";

      partitions = {
        root = {
          priority = 1;
          end = "-4G";
          type = "6A898CC3-1DD2-11B2-99A6-080020736631";
          device = "/dev/disk/by-uuid/34223ccd-07a5-4c1c-b2d6-f49246dcb9a8";

          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };

        swap = {
          priority = 2;
          end = "-512M";
          type = "8200";
          device = "/dev/disk/by-uuid/0f02375d-b47b-45c7-a0d3-391c39cb2570";
          content.type = "swap";
        };

        ESP = {
          priority = 3;
          size = "100%";
          type = "EF00";
          device = "/dev/disk/by-uuid/F33A-753F";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
      };
    };
  };
}
