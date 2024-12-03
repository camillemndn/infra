{
  deluge-storm = import ./services/web-apps/deluge-storm;
  gdm = import ./services/x11/display-managers/gdm.nix;
  hammond = import ./services/web-apps/hammond;
  koel = import ./services/audio/koel;
  logiops = import ./services/misc/logiops;
  lubelogger = import ./services/web-apps/lubelogger;
  nginx = import ./services/web-servers/nginx;
  organizr = import ./services/web-apps/organizr;
  radiogaga = import ./services/web-apps/radiogaga;
  webtrees = import ./services/web-apps/webtrees;
  yarr = import ./services/networking/yarr;
  zfs-ssh = import ./services/misc/zfs-ssh;
}
