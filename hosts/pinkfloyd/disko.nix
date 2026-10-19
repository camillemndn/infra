{ inputs, ... }:

{
  imports = [ "${inputs.disko}/module.nix" ];

  disko.devices = {
    disk.main = {
      content = {
        partitions = {
          ESP = {
            content = {
              format = "vfat";
              mountOptions = [ "umask=0077" ];
              mountpoint = "/boot";
              type = "filesystem";
            };

            size = "512M";
            type = "EF00";
          };

          luks = {
            content = {
              content = {
                type = "lvm_pv";
                vg = "pool";
              };

              name = "crypted";
              passwordFile = "/tmp/secret.key";
              settings.allowDiscards = true;
              type = "luks";
            };

            size = "100%";
          };
        };

        type = "gpt";
      };

      device = "/dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_2M242L1E8EF1";
      type = "disk";
    };

    lvm_vg.pool = {
      lvs = {
        root = {
          content = {
            format = "ext4";
            mountOptions = [ "defaults" ];
            mountpoint = "/";
            type = "filesystem";
          };

          size = "100%";
        };

        swap = {
          content.type = "swap";
          size = "16.5G";
        };
      };

      type = "lvm_vg";
    };
  };
}
