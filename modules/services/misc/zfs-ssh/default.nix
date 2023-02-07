{ config, lib, ... }:

let
  cfg = config.boot.initrd.zfs-ssh;
in
with lib;

{
  options.boot.initrd.zfs-ssh = {
    enable = mkEnableOption "Decrypt ZFS pools through SSH at boot time";
    kernelModule = mkOption {
      type = types.str;
      default = "e1000e";
    };
    keyType = mkOption {
      type = types.str;
      default = "prompt";
    };
  };

  config = mkIf cfg.enable {
    networking.useDHCP = mkDefault true;

    boot.initrd.availableKernelModules = [ cfg.kernelModule ];

    services.zfs.trim.enable = true;

    boot.initrd.postDeviceCommands = mkIf (cfg.keyType == "usb") ''
      cat <<EOF > /root/.profile
      if pgrep -x "zfs" > /dev/null
      then
        mkdir /mnt
        mount -t ext2 /dev/sda2 /mnt
        cat /mnt/key | zfs load-key -a
        killall zfs
      else
        echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
      fi
      EOF
    '';

    boot.initrd.network = {
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`,
      # so your initrd can load it!
      # Static ip addresses might be configured using the ip argument in kernel command line:
      # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
      enable = true;
      ssh = {
        enable = true;
        # To prevent ssh clients from freaking out because a different host key is used,
        # a different port for ssh is useful (assuming the same host has also a regular sshd running)
        port = 60;
        # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
        # the keys are copied to initrd from the path specified; multiple keys can be set
        # you can generate any number of host keys using
        # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
        hostKeys = [ /etc/secrets/initrd/ssh_host_rsa_key ];
        # public ssh key used for login
        authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCldNMW3TTRzcxoY3SQiF05K3p2XvKeh4HwAns28G0DyrLgP3pJ12z6ZH5g0wUBLwYnViri8diEr3DY0zGYHqYEvk40lKwj2hzd9g2Vm3M7BNHiC8f2cKy/4jOvgyT1czCMNc0Z8nZe4CEtNPO4bjX54QdBUod6FcgmAhXf7f3j3YC2YMkiRRKwBZ/oQ/p25IYaEp4zYMTyYbR6C1oW237152lqTMhVePEMaFC9Mh85zLAe33Y4cuDAS/GcrdPCyIBDkmuvl/DncAkfcETkb/JxkeoXx8ORt5mLdfXWFBPJQzzgkKCyRYbAEF2mD7RaK0Ow+afVHMV7fzYGdw5SRdxZzcVOzPwG9d2IVOe88vzePMqpIuqPHzsmlWhUQMkwGAGEV/l5tt0KKXWY3rrFay4RmkR32pKZoeTiLzya4tujGD2EnWNu08BK+F5zZNFk64I0O9PzQqk3yjwaE3aYLfrvcHkCf1Ze5p9KWcBFW16U50lpt8ngY2j+ibkOVhsaPnk= camille@LAPTOP-KTL0BN8G" ];
      };
      # this will automatically load the zfs password prompt on login
      # and kill the other prompt so boot can continue
      postCommands = ''
        cat <<EOF > /root/.profile
        if pgrep -x "zfs" > /dev/null
        then
          zfs load-key -a
          killall zfs
        else
          echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
        fi
        EOF
      '';
    };
  };
}
