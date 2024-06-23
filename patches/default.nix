{
  tzupdate = builtins.fetchurl {
    url = "https://github.com/NixOS/nixpkgs/pull/316133/commits/3199ba030e1071470a7651a780041b0169e9d0b9.patch";
    sha256 = "0qqa8da0miba4v0i8ag4021n77dcw1hspc4wm6ic9a6bwvzvdmr4";
  };
}
