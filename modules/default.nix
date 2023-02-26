{
  # Update using $> find . -iname "default.nix" -type f
  jellyseerr = import ./services/web-apps/jellyseerr;
  filerun = import ./services/web-apps/filerun;
  hammond = import ./services/misc/hammond;
  koel = import ./services/audio/koel;
  lazylibrarian = import ./services/misc/lazylibrarian;
  logiops = import ./services/misc/logiops;
  readarr = import ./services/misc/readarr;
  organizr = import ./services/web-apps/organizr;
  overleaf = import ./services/misc/overleaf;
  sheetable = import ./services/web-apps/sheetable;
  deluge-storm = import ./services/web-apps/deluge-storm;
  webtrees = import ./services/web-apps/webtrees;
  yarr = import ./services/networking/yarr;
  zfs-ssh = import ./services/misc/zfs-ssh;
}
