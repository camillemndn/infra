{ pkgs, ... }:

{
  audiveris = pkgs.callPackage ./servers/misc/audiveris { };
  filerun = pkgs.callPackage ./servers/filerun { };
  hammond = pkgs.callPackage ./servers/misc/hammond { };
  jellyseerr = pkgs.unstable.callPackage ./servers/jellyseerr { };
  koel = pkgs.callPackage ./servers/misc/koel { };
  lazylibrarian = pkgs.unstable.callPackage ./servers/lazylibrarian { };
  organizr = pkgs.callPackage ./servers/misc/organizr { };
  overleaf = pkgs.unstable.callPackage ./servers/overleaf { };
  readarr = pkgs.callPackage ./servers/readarr { };
  sheetable = pkgs.callPackage ./servers/misc/sheetable { };
  webtrees = pkgs.callPackage ./servers/misc/webtrees { };
}
