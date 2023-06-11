{
  calibre-web = import ./services/web-apps/calibre-web.nix;
  deluge-storm = import ./services/web-apps/deluge-storm;
  gdm = import ./services/x11/display-managers/gdm.nix;
  hammond = import ./services/misc/hammond;
  koel = import ./services/audio/koel;
  lazylibrarian = import ./services/misc/lazylibrarian;
  logiops = import ./services/misc/logiops;
  organizr = import ./services/web-apps/organizr;
  sheetable = import ./services/web-apps/sheetable;
  radiogaga = import ./services/web-apps/radiogaga;
  webtrees = import ./services/web-apps/webtrees;
  yarr = import ./services/networking/yarr;
  zfs-ssh = import ./services/misc/zfs-ssh;
}
