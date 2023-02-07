{
  # Update using $> find . -iname "default.nix" -type f
  koel = import ./services/audio/koel;
  hammond = import ./services/misc/hammond;
  lazylibrarian = import ./services/misc/lazylibrarian;
  logiops = import ./services/misc/logiops;
  readarr = import ./services/misc/readarr;
  zfs-ssh = import ./services/misc/zfs-ssh;
  yarr = import ./services/networking/yarr;
  filerun = import ./services/web-apps/filerun;
  sheetable = import ./services/web-apps/sheetable;
  organizr = import ./services/web-apps/organizr;
  webtrees = import ./services/web-apps/webtrees;
}
