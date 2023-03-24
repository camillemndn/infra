{ pkgs, ... }:

with pkgs;

{
  pyalsaaudio = callPackage ../development/python-modules/pyalsaaudio { };
}
