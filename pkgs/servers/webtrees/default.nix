{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pname = "webtrees";
  version = "2.1.20";

  src = fetchzip {
    url = "https://github.com/fisharebest/webtrees/releases/download/${version}/webtrees-${version}.zip";
    sha256 = "sha256-vG9fr+lPHEoG6tU55h4xBuU+oyiBH1oiTjOxCivXcj4=";
  };

  installPhase = ''
    mkdir $out
    mv * $out
  '';

  meta = with lib; {
    description = "The web’s leading online collaborative genealogy application";
    homepage = "https://webtrees.net/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
