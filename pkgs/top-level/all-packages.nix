{ pkgs, ... }:

with pkgs;

{
  audiveris = callPackage ../applications/audio/audiveris { };
  cal-com = callPackage ../servers/cal-com { };
  catppuccin-gtk = callPackage ../applications/catppuccin/catppuccin-gtk.nix { };
  catppuccin-cursors = callPackage ../applications/catppuccin/catppuccin-cursors.nix { };
  catppuccin-folders = callPackage ../applications/catppuccin/catppuccin-folders.nix { };
  deluge-storm = callPackage ../servers/deluge-storm { };
  filerun = callPackage ../servers/filerun { };
  hammond = callPackage ../servers/hammond { };
  jitsi-excalidraw = callPackage ../servers/jitsi-excalidraw { };
  koel = callPackage ../servers/koel { };
  lazylibrarian = callPackage ../servers/lazylibrarian { };
  organizr = callPackage ../servers/organizr { };
  overleaf = callPackage ../servers/overleaf { };
  radiogaga = callPackage ../servers/radiogaga { };
  signal-desktop = unstable.callPackage ../applications/networking/instant-messengers/signal-desktop { };
  sheetable = callPackage ../servers/sheetable { };
  webtrees = callPackage ../servers/webtrees { };
  zapzap = callPackage ../applications/networking/instant-messengers/zapzap { };
  zotero-dev = unstable.callPackage ../applications/office/zotero { };
  zotero-web-library = callPackage ../servers/zotero-web-library { };
}
