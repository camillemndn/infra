# My machines' configuration.

- **zeppelin**, a NUC with a multimedia server and many other things
- **genesis**, an Asus ROG X13 convertible laptop with secure boot, Gnome and fully functional hardware except for fingerprint sensor
- **icecube**, a USB stick with ZFS, i3 and *finally* secure boot
- **wutang**, a Windows Subsystem for Linux machine
- **rush**, a Raspberry Pi 4B with UEFI
- **offspring**, an Oracle VM with monitoring services
- **radiogaga**, a Raspberry Pi 3B used as a smart alarm clock (*work in progress*)

## Install Secure Boot with sbctl

https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md

## Speed up LUKS encryption on USB

https://www.reddit.com/r/Fedora/comments/zlrmmt/disable_dmcrypt_workqeues_to_improve_ssd/

```
sudo su -
cryptsetup convert --type luks2 /dev/<disk>
cryptsetup luksOpen /dev/<disk> <name>
cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh <name>
```

## Install NixOS with ZFS

```
DISK=/dev/disk/by-id/<id>

sgdisk --zap-all $DISK
sgdisk -n3:1M:+512M -t3:EF00 $DISK
sgdisk -n1:0:+1854G -t1:BF01 $DISK
sgdisk -n2:0:0 -t2:8200 $DISK

zpool create -O mountpoint=none -O relatime=on -O compression=lz4 -O xattr=sa -O acltype=posixacl -O encryption=aes-256-gcm -O keylocation=prompt -O keyformat=passphrase -o ashift=12 -R /mnt rpool $DISK-part1
zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy rpool/home

mount -t zfs rpool/root/nixos /mnt
mkdir /mnt/home
mount -t zfs rpool/home /mnt/home
mkfs.vfat $DISK-part3
mkdir /mnt/boot
mount $DISK-part3 /mnt/boot

# If RPI4 EFI
# nix-shell -p wget unzip
# wget https://github.com/pftf/RPi4/releases/download/v1.33/RPi4_UEFI_Firmware_v1.33.zip
# unzip RPi4_UEFI_Firmware_v1.33.zip -d /mnt/boot

umount /mnt/boot
zpool export rpool
```

## Build NixOS Image with GUI for aarch64

```
docker run -it --platform linux/arm64 nixos/nix
git clone https://github.com/NixOS/nixpkgs.git --depth 1

# fetch and check out the latest release tag
# apply changes to `https://github.com/NixOS/nixpkgs/compare/master...Thra11:nixpkgs:aarch64-graphical-iso` from https://github.com/NixOS/nixpkgs/compare/master...Thra11:nixpkgs:aarch64-graphical-iso

nix-build -A config.system.build.isoImage -I nixos-config=modules/installer/cd-dvd/installation-cd-graphical-gnome.nix default.nix
```
