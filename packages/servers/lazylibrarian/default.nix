{ lib, stdenv, fetchFromGitLab, ... }:

stdenv.mkDerivation rec {
  pname = "lazylibrarian";
  version = "master";

  src = fetchFromGitLab {
    owner = "LazyLibrarian";
    repo = pname;
    rev = "e3013f311f36e0b7c3756cb2424e61060712e6cf";
    sha256 = "01x3vrxl4rwc72wgq1nqw4394xbsvjfsnbrf98316rzla6f569v9";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out/.
  '';

  meta = with lib; {
    description = "LazyLibrarian is a SickBeard, CouchPotato, Headphones-like application for ebooks, audiobooks and magazines";
    homepage = "https://lazylibrarian.gitlab.io/";
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [ camillemndn ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
  };
}
