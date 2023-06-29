{ pkgs, ... }:

let
  inherit (pkgs) callPackage;
in

{
  audiveris = callPackage ../applications/audio/audiveris { };
  catppuccin-cursors = callPackage ../data/icons/catppuccin-cursors { };
  catppuccin-folders = callPackage ../data/icons/catppuccin-folders { };
  catppuccin-gtk = callPackage ../data/themes/catppuccin-gtk { };
  deluge-storm = callPackage ../servers/deluge-storm { };
  hammond = callPackage ../servers/hammond { };
  harmony-assistant = callPackage ../applications/audio/harmony-assistant { };
  koel = callPackage ../servers/koel { };
  lazylibrarian = callPackage ../servers/lazylibrarian { };
  organizr = callPackage ../servers/organizr { };
  pandoc = callPackage ../development/tools/pandoc { };
  quarto = callPackage ../development/libraries/quarto { };
  radiogaga = callPackage ../servers/radiogaga { };
  sheetable = callPackage ../servers/sheetable { };
  webtrees = callPackage ../servers/webtrees { };
  zapzap = callPackage ../applications/networking/instant-messengers/zapzap { };
  zotero = callPackage ../applications/office/zotero { };
  zotero-web-library = callPackage ../servers/zotero-web-library { };
}
