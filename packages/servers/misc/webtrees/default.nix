{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pname = "webtrees";
  version = "2.1.16";

  src = fetchzip {
    url = "https://github.com/fisharebest/webtrees/releases/download/${version}/webtrees-${version}.zip";
    sha256 = "sha256-bOLJahf4meP1H43Cmbp2ZoNV7B0WL+8F1vPzDuEWORY=";
  };

  installPhase = ''
    mkdir $out
    mv * $out
  '';

  meta = with lib; {
    description = "The web’s leading online collaborative genealogy application";
    homepage = "https://webtrees.net/";
    license = licenses.gpl2Only;
    # maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.all;
  };
}
