{ pkgs, ... }:

{
  audiveris = pkgs.callPackage ./servers/misc/audiveris { };
  hammond = pkgs.callPackage ./servers/misc/hammond { };
  koel = pkgs.callPackage ./servers/misc/koel { };
  webtrees = pkgs.callPackage ./servers/misc/webtrees { };
  sheetable = pkgs.callPackage ./servers/misc/sheetable { };
  organizr = pkgs.callPackage ./servers/misc/organizr { };
  readarr = pkgs.callPackage ./servers/readarr { };
  lazylibrarian = pkgs.callPackage ./servers/lazylibrarian { };
  filerun = pkgs.callPackage ./servers/filerun { };
}
