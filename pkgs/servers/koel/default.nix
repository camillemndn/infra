{ stdenv, lib, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "koel";
  version = "6.11.2";

  src = fetchurl {
    url = "https://github.com/koel/koel/releases/download/v${version}/koel-v${version}.tar.gz";
    sha256 = "sha256-2zRLknvnpANxLD9BmCiMAXkt0dxUr5t2tOoW1uYuXcc=";
  };

  installPhase = ''
    mkdir $out
    shopt -s dotglob
    mv * $out
    touch $out/.env
  '';

  meta = with lib; {
    description = "A simple web-based personal audio streaming service written in Vue and Laravel.";
    homepage = "https://koel.dev/";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
