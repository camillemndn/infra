{ pkgs, ... }:

with pkgs;

{
  audiveris = callPackage ../applications/audio/audiveris { };
  cal-com = callPackage ../servers/cal-com { };
  deluge-storm = callPackage ../servers/deluge-storm { };
  filerun = callPackage ../servers/filerun { };
  hammond = callPackage ../servers/hammond { };
  koel = callPackage ../servers/koel { };
  lazylibrarian = callPackage ../servers/lazylibrarian { };
  organizr = callPackage ../servers/organizr { };
  overleaf = callPackage ../servers/overleaf { };
  sheetable = callPackage ../servers/sheetable { };
  webtrees = callPackage ../servers/webtrees { };
  zapzap = callPackage ../applications/networking/instant-messengers/zapzap { };
  zotero-dev = unstable.callPackage ../applications/office/zotero { };
  zotero-web-library = callPackage ../servers/zotero-web-library { };
}
