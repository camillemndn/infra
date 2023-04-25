{ pkgs, ... }:

with pkgs;

{
  pdftocgen = callPackage ../development/python-modules/pdftocgen { };
  pyalsaaudio = callPackage ../development/python-modules/pyalsaaudio { };
}
