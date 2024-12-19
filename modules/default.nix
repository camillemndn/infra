{
  gdm = import ./services/x11/display-managers/gdm.nix;
  koel = import ./services/audio/koel;
  logiops = import ./services/misc/logiops;
  lubelogger = import ./services/web-apps/lubelogger;
  nginx = import ./services/web-servers/nginx;
  radiogaga = import ./services/web-apps/radiogaga;
  webtrees = import ./services/web-apps/webtrees;
  yarr = import ./services/networking/yarr;
  zfs-ssh = import ./services/misc/zfs-ssh;
}
