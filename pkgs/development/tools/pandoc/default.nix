{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "pandoc";
  version = "3.1.2";

  src = fetchurl {
    url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
    hash = "sha256-Thxgf35OkkP6Hh9bIIzU8dP2/QVdXYw5ugzcOGROHDU=";
  };

  buildInputs = [ autoPatchelfHook ];
  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  meta = with lib; {
    description = "Universal markup converter";
    homepage = "https://github.com/jgm/pandoc";
    changelog = "https://github.com/jgm/pandoc/blob/${src.rev}/changelog.md";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ camillemndn ];
  };
}
