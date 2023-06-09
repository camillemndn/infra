{ pkgs, ... }:

let
  callPackage = pkgs.callPackage;
in

{
  audiveris = callPackage ../applications/audio/audiveris { };
  # cal-com = callPackage ../servers/cal-com { };
  catppuccin-gtk = callPackage ../data/themes/catppuccin-gtk { };
  catppuccin-cursors = callPackage ../data/icons/catppuccin-cursors { };
  catppuccin-folders = callPackage ../data/icons/catppuccin-folders { };
  deluge-storm = callPackage ../servers/deluge-storm { };
  filerun = callPackage ../servers/filerun { };
  hammond = callPackage ../servers/hammond { };
  koel = callPackage ../servers/koel { };
  lazylibrarian = callPackage ../servers/lazylibrarian { };
  organizr = callPackage ../servers/organizr { };
  radiogaga = callPackage ../servers/radiogaga { };
  # signal-desktop = callPackage ../applications/networking/instant-messengers/signal-desktop { };
  sheetable = callPackage ../servers/sheetable { };
  webtrees = callPackage ../servers/webtrees { };
  zapzap = callPackage ../applications/networking/instant-messengers/zapzap { };
  zotero = callPackage ../applications/office/zotero { };
  zotero-web-library = callPackage ../servers/zotero-web-library { };
}
