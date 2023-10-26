{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pname = "webtrees";
  version = "2.1.18";

  src = fetchzip {
    url = "https://github.com/fisharebest/webtrees/releases/download/${version}/webtrees-${version}.zip";
    sha256 = "sha256-m+jo8ejQKeLQSmcbzlMdu/AZTptUdhvAo67b1vaa+LU=";
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
